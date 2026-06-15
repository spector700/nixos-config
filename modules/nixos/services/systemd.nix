{
  systemd =
    let
      timeoutConfig = {
        DefaultTimeoutStartSec = 10;
        DefaultTimeoutStopSec = 10;
        DefaultTimeoutAbortSec = 10;
        DefaultDeviceTimeoutSec = 10;
      };
    in
    {
      # avoid hanging the system for too long on boot or shutdown.
      user.settings.Manager = timeoutConfig;
    };
}
