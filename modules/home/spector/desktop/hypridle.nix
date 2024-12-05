{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.desktop.hypridle;
in
{
  options.modules.desktop.hypridle = {
    enable = mkEnableOption "Enable the hypridle service";
  };

  config = mkIf cfg.enable {
    # screen idle
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = lib.getExe config.programs.hyprlock.package;
        };

        listener = [
          {
            timeout = 360;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
        ];
      };
    };

    systemd.user.services.hypridle.Unit.After = lib.mkForce "graphical-session.target";

    # Use in place of hypridle's before_sleep_cmd, since systemd does not wait for
    # it to complete
    systemd.user.services.before-suspend =
      let
        suspendScript = pkgs.writeShellScript "suspend-script" ''
          # Pause media before suspend
          ${lib.getExe pkgs.playerctl} pause

          # Lock the compositor
          ${pkgs.systemd}/bin/loginctl lock-session

          # Wait for lockscreen to be up
          sleep 3
        '';
      in
      {
        Install.RequiredBy = [ "suspend.target" ];

        Service = {
          ExecStart = suspendScript.outPath;
          Type = "forking";
        };

        Unit = {
          Description = "Commands run before suspend";
          PartOf = "suspend.target";
        };
      };
  };
}
