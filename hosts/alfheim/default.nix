{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
let
  user = config.modules.os.mainUser;
  toPyBoolStr = value: if value then "True" else "False";

  # Disable openrazer setting the DPI
  openrazerDaemonConfig = pkgs.writeText "openrazer-razer.conf" ''
    [General]
    verbose_logging = ${toPyBoolStr config.hardware.openrazer.verboseLogging}

    [Startup]
    sync_effects_enabled = ${toPyBoolStr config.hardware.openrazer.syncEffectsEnabled}
    devices_off_on_screensaver = ${toPyBoolStr config.hardware.openrazer.devicesOffOnScreensaver}
    battery_notifier = ${toPyBoolStr config.hardware.openrazer.batteryNotifier.enable}
    battery_notifier_freq = ${toString config.hardware.openrazer.batteryNotifier.frequency}
    battery_notifier_percent = ${toString config.hardware.openrazer.batteryNotifier.percentage}
    restore_persistence = False

    [Statistics]
    key_statistics = ${toPyBoolStr config.hardware.openrazer.keyStatistics}
  '';
in
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
    roles = {
      video.enable = true;
    };

    programs = {
      thunar.enable = true;
    };
  };

  hardware = {
    # Udev rules for vial
    keyboard.qmk.enable = true;

    openrazer = {
      enable = true;
      batteryNotifier = {
        enable = true;
        frequency = 6000;
        percentage = 10;
      };
      syncEffectsEnabled = false;
      users = [ "${user}" ];
    };
  };

  systemd.user.services.openrazer-daemon.serviceConfig.ExecStart = lib.mkForce (
    "${config.hardware.openrazer.packages.daemon}/bin/openrazer-daemon "
    + "--config ${openrazerDaemonConfig} --foreground"
  );
}
