{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.modules.homelab.prometheus;

  defaultAlertRules = ''
    groups:
      - name: homelab
        rules:
          - alert: NodeDown
            expr: up == 0
            for: 2m
            labels:
              severity: critical
            annotations:
              summary: "Host {{ $labels.instance }} is unreachable"
              description: "{{ $labels.job }} target {{ $labels.instance }} has been down for more than 2 minutes."

          - alert: HighCPU
            expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: "High CPU usage on {{ $labels.instance }}"
              description: "CPU usage is {{ $value | printf \"%.1f\" }}% on {{ $labels.instance }}."

          - alert: HighMemory
            expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
            for: 10m
            labels:
              severity: warning
            annotations:
              summary: "High memory usage on {{ $labels.instance }}"
              description: "Memory usage is {{ $value | printf \"%.1f\" }}% on {{ $labels.instance }}."

          - alert: DiskFilling
            expr: (1 - (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"})) * 100 > 80
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "Disk filling up on {{ $labels.instance }}"
              description: "Filesystem {{ $labels.mountpoint }} on {{ $labels.instance }} is {{ $value | printf \"%.1f\" }}% full."

          - alert: DiskCritical
            expr: (1 - (node_filesystem_avail_bytes{fstype!~"tmpfs|overlay"} / node_filesystem_size_bytes{fstype!~"tmpfs|overlay"})) * 100 > 95
            for: 2m
            labels:
              severity: critical
            annotations:
              summary: "Disk critically full on {{ $labels.instance }}"
              description: "Filesystem {{ $labels.mountpoint }} on {{ $labels.instance }} is {{ $value | printf \"%.1f\" }}% full."

          - alert: SystemdServiceFailed
            expr: node_systemd_unit_state{state="failed"} == 1
            for: 2m
            labels:
              severity: warning
            annotations:
              summary: "Systemd service failed on {{ $labels.instance }}"
              description: "Service {{ $labels.name }} is in failed state on {{ $labels.instance }}."
  '';
in
{
  options.modules.homelab.prometheus = {
    enable = mkEnableOption "Enable Prometheus metrics collection";

    enableDefaultAlerts = mkOption {
      type = types.bool;
      default = true;
      description = "Enable default homelab alert rules (node down, high CPU/memory/disk, failed services).";
    };

    remoteTargets = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            job_name = mkOption {
              type = types.str;
              description = "Prometheus job name for this target group.";
            };
            targets = mkOption {
              type = types.listOf types.str;
              description = "List of host:port scrape targets.";
            };
            scrape_interval = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Override scrape interval (e.g. \"30s\"). Uses global default if null.";
            };
          };
        }
      );
      default = [ ];
      description = "Additional remote Prometheus scrape targets (scraped over Tailscale).";
    };
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 9090;
      # Reduce retention from 30d to 15d -- VPS disk is limited
      extraFlags = [ "--storage.tsdb.retention.time=15d" ];

      exporters.node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "systemd"
          "processes"
          "interrupts"
          "tcpstat"
        ];
      };

      # Wire up Alertmanager
      alertmanagers = mkIf config.modules.homelab.alertmanager.enable [
        {
          static_configs = [
            {
              targets = [ "127.0.0.1:9093" ];
            }
          ];
        }
      ];

      # Alert rules
      rules = lib.optional cfg.enableDefaultAlerts defaultAlertRules;

      scrapeConfigs =
        [
          # vanaheim itself
          {
            job_name = "vanaheim-node";
            static_configs = [
              {
                targets = [ "localhost:9100" ];
              }
            ];
          }
        ]
        ++
        # Remote targets (Unraid, HA VM, etc.) over Tailscale
        map (t: {
          inherit (t) job_name;
          static_configs = [ { inherit (t) targets; } ];
        } // lib.optionalAttrs (t.scrape_interval != null) { scrape_interval = t.scrape_interval; }) cfg.remoteTargets;
    };

    # Allow Prometheus to be scraped from Tailscale (e.g. for federation later)
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 9090 9100 ];

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      {
        directory = "/var/lib/prometheus2";
        user = "prometheus";
        group = "prometheus";
        mode = "0750";
      }
    ];
  };
}
