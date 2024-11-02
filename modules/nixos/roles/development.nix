{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.roles.development;
in
{
  options.modules.roles.development = {
    enable = mkEnableOption "Enable the Development role";
  };

  config = mkIf cfg.enable {
    # for platformio esp32 development
    # nix-ld is needed for the platformio vscode extension to be able to run binaries
    programs.nix-ld.enable = true;

    services.udev.packages = with pkgs; [
      platformio
      openocd
    ];

  };
}
