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
    mkAfter
    ;
  cfg = config.modules.services.sunshine;
  user = config.modules.os.mainUser;

  getHyprlandSignature = pkgs.writeShellScript "getHyprlandSignature" ''
    ${pkgs.findutils}/bin/find "$XDG_RUNTIME_DIR/hypr/" -maxdepth 1 -type d |
      ${pkgs.gnugrep}/bin/grep -v "^$XDG_RUNTIME_DIR/hypr/$" |
      ${pkgs.gawk}/bin/awk -F'/' '{print $NF}'
  '';

  onConnect = pkgs.writeShellScript "onConnect" ''
    export PATH="${pkgs.hyprland}/bin:$PATH"

    HYPRLAND_INSTANCE_SIGNATURE=$(${getHyprlandSignature})
    export HYPRLAND_INSTANCE_SIGNATURE

    hyprctl output create headless Virtual
    hyprctl keyword monitor Virtual,"$SUNSHINE_CLIENT_WIDTH"x"$SUNSHINE_CLIENT_HEIGHT"@"$SUNSHINE_CLIENT_FPS",auto,1

    hyprctl dispatch workspace 8
    hyprctl dispatch moveworkspacetomonitor "8" "Virtual"
    # hyprctl dispatch dpms off DP-2
    # hyprctl dispatch dpms off DP-3
    ${getExe pkgs.wlopm} --off DP-2
    ${getExe pkgs.wlopm} --off DP-3
  '';

  onDisconnect = pkgs.writeShellScript "onDisconnect" ''
    export PATH="${pkgs.hyprland}/bin:$PATH"

    HYPRLAND_INSTANCE_SIGNATURE=$(${getHyprlandSignature})
    export HYPRLAND_INSTANCE_SIGNATURE

    ${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://close/bigpicture

    hyprctl dispatch moveworkspacetomonitor "8" "DP-2"
    hyprctl output remove Virtual
    ${getExe pkgs.wlopm} --on DP-2
    ${getExe pkgs.wlopm} --on DP-3
    # hyprctl dispatch dpms on DP-2
    # hyprctl dispatch dpms on DP-3
    # sleep 1 && hyprctl reload
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
              detached = [ "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture" ];
              exclude-global-prep-cmd = "false";
              auto-detach = "true";
            }
          ];
        };
      };
    }
    (mkIf config.modules.display.desktop.hyprland.enable {
      home-manager.users.${user}.config = {
        wayland.windowManager.hyprland.settings = {
          # add a virtual monitor for sunshine
          monitor = mkAfter [ "Virtual,1920x1080@60,auto,1" ];
        };
      };
    })
  ]);
}
