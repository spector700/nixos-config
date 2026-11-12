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

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" ];
    # For building other systems on this system
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

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

  programs.nix-ld.enable = true;

  networking.hostName = "alfheim";

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  ## NIXOS
  modules = {
    roles = {
      development.enable = false;
      gaming.enable = true;
      video.enable = true;
    };

    hardware = {
      cpu.type = "amd";
      gpu.type = "nvidia";
      openrgb.enable = true;
    };

    services = {
      sunshine.enable = true;
      syncthing.enable = true;
    };

    desktop = {
      monitors = [
        {
          name = "DP-2";
          resolution = "3440x1440";
          position = "1152x420";
          refreshRate = 100;
          scale = "1.25";
          primary = true;
          workspaces = [
            1
            2
            3
            7
            8
            9
          ];
        }
        {
          name = "DP-3";
          resolution = "3840x2160";
          scale = "1.875";
          refreshRate = 60;
          rotation = "transform,1";
          workspaces = [
            4
            5
            6
          ];
        }
      ];
    };

    programs = {
      thunar.enable = true;
    };

    os = {
      mainUser = "spector";
      autoLogin = true;
    };

    boot = {
      enableKernelTweaks = true;
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
