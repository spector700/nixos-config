{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.programs.quickshell;

in
{
  options.modules.desktop.quickshell = {
    enable = mkEnableOption "Enable the hyprpanel taskbar";
  };

  config = mkIf cfg.enable {
    programs.quickshell = {
      enable = true;
    };

    systemd.user.services.quickshell-lock = mkIf cfg.enable {
      Unit = {
        Description = "launch quickshell lock";
        Before = "lock.target";
      };
      Install.WantedBy = [ "lock.target" ];
      Service.ExecStart = "${lib.getExe cfg.package} ipc call lock lock";
    };
  };
}
