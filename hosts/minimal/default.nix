{
  pkgs,
  config,
  inputs,
  ...
}:
let
  user = config.modules.os.mainUser;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/nvme0n1" ]; })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "minimal";

  # home-manager modules
  home-manager.users.${user}.config = {
    sops.secrets = {
      "keys/ssh/${user}_${config.networking.hostName}" = {
        path = "/home/${user}/.ssh/id_spector";
      };
    };

  };

  modules = {
    hardware = {
      cpu.type = "amd";
      # gpu.type = "nvidia";
      sound.enable = true;
    };

    os = {
      mainUser = "spector";
      # autoLogin = true;
    };

    boot = {
      enableKernelTweaks = true;
      impermanence.enable = true;
    };
  };

  hardware = {
    # Udev rules for vial
    keyboard.qmk.enable = true;
  };
}
