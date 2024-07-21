{ config, lib, ... }:
let
  inherit (lib)
    mkDefault
    mkIf
    types
    mkOption
    ;

  cfg = config.modules.boot;
in
{
  options.modules.boot = {
    loader = mkOption {
      type = types.enum [ "systemd-boot" ];
      default = "systemd-boot";
      description = "The bootloader that should be used for the device.";
    };
  };

  config = mkIf (cfg.loader == "systemd-boot") {
    boot.loader = {
      systemd-boot = {
        enable = mkDefault true;
        configurationLimit = 20;
        consoleMode = mkDefault "max"; # the default is "keep", can be overriden per host if need be

        # Fix a security hole in place for backwards compatibility. See desc in
        # nixpkgs/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix
        editor = false;
      };
    };
  };
}
