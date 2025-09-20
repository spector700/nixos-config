{
  systemd =
    let
      timeoutConfig = ''
        DefaultTimeoutStartSec=10s
        DefaultTimeoutStopSec=10s
        DefaultTimeoutAbortSec=10s
        DefaultDeviceTimeoutSec=10s
      '';
    in
    {
      # avoid hanging the system for too long on boot or shutdown.
      user.extraConfig = timeoutConfig;
    };
}
