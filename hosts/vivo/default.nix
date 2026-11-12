{
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./home.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/nvme0n1" ]; })
  ];

  ## NIXOS
  modules = {
    programs = {
      thunar.enable = true;
    };

    os = {
      mainUser = "spector";
      autoLogin = true;
    };

  };

  hardware = {
    # Udev rules for vial
    keyboard.qmk.enable = true;
  };
}
