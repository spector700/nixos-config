{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.modules.desktop.bar;

in
{
  config = mkIf (cfg == "quickshell") {
    home.packages = with pkgs; [
      material-symbols
      cava
    ];

    programs.quickshell = {
      enable = true;
      package = pkgs.symlinkJoin {
        name = "quickshell-wrapped";
        paths = with pkgs; [
          quickshell
          kdePackages.kdialog
          kdePackages.qt5compat
          kdePackages.qtbase
          kdePackages.qtdeclarative
          kdePackages.qtdeclarative
          kdePackages.qtimageformats
          kdePackages.qtmultimedia
          kdePackages.qtpositioning
          kdePackages.qtquicktimeline
          kdePackages.qtsensors
          kdePackages.qtsvg
          kdePackages.qttools
          kdePackages.qttranslations
          kdePackages.qtvirtualkeyboard
          kdePackages.qtwayland
          kdePackages.syntax-highlighting
        ];
        meta.mainProgram = pkgs.quickshell.meta.mainProgram;
      };

      systemd.enable = true;
    };

    # systemd.user.services.quickshell-lock = mkIf cfg.enable {
    #   Unit = {
    #     Description = "launch quickshell lock";
    #     Before = "lock.target";
    #   };
    #   Install.WantedBy = [ "lock.target" ];
    #   Service.ExecStart = "${lib.getExe config.programs.quickshell.package} ipc call lock lock";
    # };
  };
}
