{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    getExe
    mkMerge
    ;
  cfg = config.modules.services.sunshine;
  uexec = program: "uwsm app -- ${program}";

  getHyprlandSignature = pkgs.writeShellScript "getHyprlandSignature" ''
    ${pkgs.findutils}/bin/find "$XDG_RUNTIME_DIR/hypr/" -maxdepth 1 -type d |
      ${pkgs.gnugrep}/bin/grep -v "^$XDG_RUNTIME_DIR/hypr/$" |
      ${pkgs.gawk}/bin/awk -F'/' '{print $NF}'
  '';

  onConnect = pkgs.writeShellScript "onConnect" ''
    export PATH="${pkgs.hyprland}/bin:$PATH"
    HYPRLAND_INSTANCE_SIGNATURE=$(${getHyprlandSignature})
    export HYPRLAND_INSTANCE_SIGNATURE


    # Create virtual monitor first
    hyprctl output create headless Virtual
    sleep 0.3

    # Configure virtual monitor with client settings
    hyprctl keyword monitor Virtual,"$SUNSHINE_CLIENT_WIDTH"x"$SUNSHINE_CLIENT_HEIGHT"@"$SUNSHINE_CLIENT_FPS",auto,1
    sleep 0.3

    # Move workspace 8 to virtual monitor
    hyprctl dispatch moveworkspacetomonitor "8" "Virtual"
    sleep 0.3

    # Disable animations and effects for performance
    hyprctl --batch "\
      keyword animations:enabled 0;\
      keyword decoration:shadow:enabled 0;\
      keyword decoration:blur:enabled 0;\
      keyword general:gaps_in 0;\
      keyword general:gaps_out 0;\
      keyword general:border_size 1;\
      keyword decoration:rounding 0;\
      keyword misc:new_window_takes_over_fullscreen 1;\
      keyword misc:mouse_move_enables_dpms false;\
      keyword misc:key_press_enables_dpms false;\
      keyword misc:exit_window_retains_fullscreen true" # if a fullscreen window is closed, the next window will be fullscreened if this is true
    sleep 0.3

    # Disable physical monitors
    # DMPS does not work reliably, so just disable the monitors
    # hyprctl keyword monitor DP-2,disable
    # hyprctl keyword monitor DP-3,disable
    hyprctl dispatch dpms off DP-2
    hyprctl dispatch dpms off DP-3
    sleep 0.5

    # Switch to workspace 8 to ensure focus
    hyprctl dispatch workspace 8
    sleep 0.2

    ${pkgs.steam}/bin/steam steam://open/bigpicture &
  '';

  onDisconnect = pkgs.writeShellScript "onDisconnect" ''
    export PATH="${pkgs.hyprland}/bin:$PATH"
    HYPRLAND_INSTANCE_SIGNATURE=$(${getHyprlandSignature})
    export HYPRLAND_INSTANCE_SIGNATURE

    ${pkgs.steam}/bin/steam steam://close/bigpicture &

    # Re-enable physical monitors
    # hyprctl keyword monitor DP-2,enable
    # hyprctl keyword monitor DP-3,enable

    hyprctl dispatch dpms on DP-2
    hyprctl dispatch dpms on DP-3
    sleep 0.5

    # Move workspace back to physical monitor
    hyprctl dispatch moveworkspacetomonitor "8" "DP-2"
    sleep 0.3

    hyprctl output remove Virtual
    sleep 0.3

    # Reset config and monitors
    hyprctl reload
    sleep 0.3

  '';
in
{
  options.modules.services.sunshine = {
    enable = mkEnableOption "Enable sunshine game streaming service";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Enable self-hosted game streaming
      services.sunshine = {
        enable = true;
        package = pkgs.sunshine.override {
          cudaSupport = true;
        };
        capSysAdmin = false;
        openFirewall = true;
        settings = {
          # Target the virtual monitor created in hyprland config
          output_name = 2;
          min_log_level = "info";
        };
        applications = {
          env = {
            PATH = "$(PATH):$(HOME)/.local/bin";
          };
          apps = lib.mkAfter [
            {
              name = "Steam";
              image-path = "steam.png";
              prep-cmd = [
                {
                  do = onConnect;
                  undo = onDisconnect;
                }
              ];
              # detached = [ "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture" ];
              exclude-global-prep-cmd = "false";
              auto-detach = "true";
              # wait-all = "false";
            }
          ];
        };
      };
    }
  ]);
}
