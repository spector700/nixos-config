{
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/nvme0n1" ]; })
  ];

  ## NIXOS
  hardware = {
    # Udev rules for vial
    keyboard.qmk.enable = true;
  };
}
