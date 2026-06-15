{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.modules.homelab.alloy;
  lokiPort = toString config.services.loki.configuration.server.http_listen_port;
  tailscaleIP = "100.105.161.102";

  alloyConfig = pkgs.writeText "config.alloy" ''
    // ----------------------------------------------------------------
    // Local: ship vanaheim's own systemd journal to Loki
    // ----------------------------------------------------------------
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

    ${lib.optionalString cfg.enableRemoteIngestion ''
      // ----------------------------------------------------------------
      // Remote ingestion: accept log pushes from homelab Alloy agents
      // Listens on Tailscale interface only (${tailscaleIP}:3031)
      // ----------------------------------------------------------------
      loki.source.api "remote_agents" {
        http {
          listen_address = "${tailscaleIP}"
          listen_port    = 3031
        }
        forward_to = [loki.relabel.remote.receiver]
      }

      loki.relabel "remote" {
        forward_to = [loki.write.local.receiver]

        // Preserve all labels sent by remote agents
        rule {
          action = "labelmap"
          regex  = "(.*)"
        }
      }
    ''}
  '';
in
{
  options.modules.homelab.alloy = {
    enable = mkEnableOption "Enable Grafana Alloy log shipper";

    enableRemoteIngestion = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Accept log pushes from remote Alloy agents (Unraid, HA VM, etc.)
        via a Loki-compatible HTTP endpoint on the Tailscale interface.
        Listens on ${tailscaleIP}:3031.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.alloy = {
      enable = true;
      configPath = alloyConfig;
    };

    # Open Tailscale interface for remote log ingestion
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = mkIf cfg.enableRemoteIngestion [
      3031
    ];
  };
}
