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
