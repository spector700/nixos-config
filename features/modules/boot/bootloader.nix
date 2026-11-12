_: {
  flake.aspects.bootloader.nixos =
    { config, lib, ... }:
    let
      inherit (lib)
        mkDefault
        mkIf
        types
        mkOption
        mkMerge
        mkForce
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

      config = {
        boot = {
          # whether to enable support for Linux MD RAID arrays
          swraid.enable = mkDefault false;

          loader =
            mkMerge [
              {
                # if set to 0, space needs to be held to get the boot menu to appear
                timeout = mkForce 1;

                # whether to copy the necessary boot files into /boot
                # so that /nix/store is not needed by the boot loader.
                generationsDir.copyKernels = true;

                # allow installation to modify EFI variables
                efi.canTouchEfiVariables = true;
              }

            ]
            ++ [
              mkIf
              (cfg.loader == "systemd-boot")
              {
                systemd-boot = {
                  enable = mkDefault true;
                  configurationLimit = 20;
                  consoleMode = mkDefault "max"; # the default is "keep", can be overriden per host if need be

                  # Fix a security hole in place for backwards compatibility. See desc in
                  # nixpkgs/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix
                  editor = false;
                };
              }
            ];
        };
      };
    };
}
