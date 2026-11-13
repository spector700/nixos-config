_: {
  flake.aspects.openrazer.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      toPyBoolStr = value: if value then "True" else "False";

      # Disable OpenRazer restoring the mouse DPI.
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
      hardware.openrazer = {
        enable = true;
        batteryNotifier = {
          enable = true;
          frequency = 6000;
          percentage = 10;
        };
        syncEffectsEnabled = false;
        users = [ config.modules.os.mainUser ];
      };

      systemd.user.services.openrazer-daemon.serviceConfig.ExecStart = lib.mkForce (
        "${config.hardware.openrazer.packages.daemon}/bin/openrazer-daemon "
        + "--config ${openrazerDaemonConfig} --foreground"
      );
    };
}
