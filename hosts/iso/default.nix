{
  pkgs,
  config,
  inputs,
  modulesPath,
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
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot = {
    # kernelPackages = pkgs.linuxPackages_6_6; # fix Freezing in games
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "iso";

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

      bluetooth.enable = true;
      printing.enable = true;
    };

    display = {
      # gpuAcceleration.enable = true;
      desktop.hyprland.enable = true;

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
