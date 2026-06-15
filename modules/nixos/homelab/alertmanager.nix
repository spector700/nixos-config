{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.homelab.alertmanager;
in
{
  options.modules.homelab.alertmanager = {
    enable = mkEnableOption "Enable Prometheus Alertmanager";
  };

  config = mkIf cfg.enable {
    services.prometheus.alertmanager = {
      enable = true;
      port = 9093;
      # Bind to localhost only
      listenAddress = "127.0.0.1";

      configuration = {
        global = {
          # How long to wait before sending a resolved notification
          resolve_timeout = "5m";
        };

        route = {
          group_by = [ "alertname" "instance" ];
          # Wait to batch alerts before sending
          group_wait = "30s";
          group_interval = "5m";
          # Resend still-firing alerts every hour
          repeat_interval = "1h";
          receiver = "signal-webhook";

          routes = [
            {
              # Critical alerts fire faster
              match.severity = "critical";
              group_wait = "10s";
              repeat_interval = "30m";
              receiver = "signal-webhook";
            }
          ];
        };

        receivers = [
          {
            name = "signal-webhook";
            webhook_configs = [
              {
                # signal-cli-rest-api will run as a container -- added in a later PR
                url = "http://127.0.0.1:8080/v2/send";
                send_resolved = true;
              }
            ];
          }
        ];

        inhibit_rules = [
          {
            # If a node is down, suppress other alerts from the same instance
            source_match.severity = "critical";
            target_match.severity = "warning";
            equal = [ "instance" ];
          }
        ];
      };
    };

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      {
        directory = "/var/lib/prometheus/alertmanager";
        user = "prometheus";
        group = "prometheus";
        mode = "0750";
      }
    ];
  };
}
