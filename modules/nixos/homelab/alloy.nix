{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.homelab.alloy;
  lokiPort = toString config.services.loki.configuration.server.http_listen_port;
in
{
  options.modules.homelab.alloy = {
    enable = mkEnableOption "Enable Grafana Alloy log shipper";
  };

  config = mkIf cfg.enable {
    environment.etc."alloy/config.alloy".text = ''
      loki.source.journal "system" {
        max_age    = "12h"
        labels     = {
          job  = "systemd-journal",
          host = constants.hostname,
        }
        forward_to = [loki.relabel.journal.receiver]
      }

      loki.relabel "journal" {
        forward_to = [loki.write.local.receiver]

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
      }

      loki.write "local" {
        endpoint {
          url = "http://127.0.0.1:${lokiPort}/loki/api/v1/push"
        }
      }
    '';

    services.alloy.enable = true;
  };
}
