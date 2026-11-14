{
  inputs,
  ...
}:
{
  imports = [
    ./home.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/sda" ]; })
  ];

  ## NIXOS
  hardware = {
    # Udev rules for vial
    keyboard.qmk.enable = true;
  };
}
