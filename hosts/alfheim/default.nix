{
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./home.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/sda" ]; })
  ];

  # DIAGNOSTIC: persist journal across reboots so failed boot logs are readable
  services.journald.settings.Journal = {
    Storage = "persistent";
    SyncIntervalSec = 1;
    SystemMaxUse = "2G";
  };

  environment.persistence."/persist".directories = [
    "/var/log"
    "/var/lib/systemd/pstore"
  ];

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  ## NIXOS
  modules = {

    programs = {
      thunar.enable = true;
    };
  };

  hardware = {
    # Udev rules for vial
    keyboard.qmk.enable = true;
  };
}
