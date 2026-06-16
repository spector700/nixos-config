{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.homelab.grafana;

  lokiUid = "loki";
  prometheusUid = "prometheus";

  # Dashboard JSON defined as a Nix attrset — serialised at build time.
  # Labels: host=<hostname> — also job="systemd-journal", unit=<systemd-unit> from vanaheim alloy
  systemLogsDashboard = {
    id = null;
    uid = "system-logs";
    title = "System Logs";
    tags = [
      "loki"
      "systemd"
      "vanaheim"
    ];
    timezone = "browser";
    schemaVersion = 38;
    version = 1;
    refresh = "30s";
    time = {
      from = "now-1h";
      to = "now";
    };

    # Dropdown to filter by systemd unit
    templating.list = [
      {
        name = "host";
        label = "Host";
        type = "query";
        datasource = {
          type = "loki";
          uid = lokiUid;
        };
        definition = "label_values(host)";
        query = {
          query = "label_values(host)";
          refId = "LokiVariableQueryEditor-VariableQuery";
        };
        refresh = 2;
        multi = true;
        includeAll = true;
        allValue = ".+";
        current = {
          selected = true;
          text = "All";
          value = "$__all";
        };
      }
      {
        name = "unit";
        label = "Unit";
        type = "query";
        datasource = {
          type = "loki";
          uid = lokiUid;
        };
        definition = "label_values({job=\"systemd-journal\",host=~\"$host\"},unit)";
        query = {
          query = "label_values({job=\"systemd-journal\",host=~\"$host\"},unit)";
          refId = "LokiVariableQueryEditor-VariableQuery";
        };
        refresh = 2;
        multi = true;
        includeAll = true;
        allValue = ".+";
        current = { };
      }
    ];

    panels = [
      # --- Log rate over time, split by unit ---
      {
        id = 1;
        type = "timeseries";
        title = "Log Rate by Unit (logs/s)";
        gridPos = {
          h = 8;
          w = 24;
          x = 0;
          y = 0;
        };
        datasource = {
          type = "loki";
          uid = lokiUid;
        };
        targets = [
          {
            datasource = {
              type = "loki";
              uid = lokiUid;
            };
            expr = "sum by(host) (rate({host=~\"$host\"}[$__rate_interval]))";
            legendFormat = "{{host}}";
            refId = "A";
          }
        ];
        fieldConfig = {
          defaults = {
            custom = {
              drawStyle = "line";
              lineInterpolation = "linear";
              spanNulls = false;
              fillOpacity = 10;
            };
            unit = "short";
            min = 0;
          };
          overrides = [ ];
        };
        options = {
          tooltip = {
            mode = "multi";
            sort = "desc";
          };
          legend = {
            displayMode = "table";
            placement = "bottom";
            calcs = [
              "sum"
              "max"
            ];
          };
        };
      }

      {
        id = 2;
        type = "logs";
        title = "Log Lines";
        gridPos = {
          h = 16;
          w = 24;
          x = 0;
          y = 8;
        };
        datasource = {
          type = "loki";
          uid = lokiUid;
        };
        targets = [
          {
            datasource = {
              type = "loki";
              uid = lokiUid;
            };
            expr = "{host=~\"$host\"}";
            refId = "A";
          }
        ];
        options = {
          showTime = true;
          showLabels = false;
          showCommonLabels = false;
          wrapLogMessage = true;
          prettifyLogMessage = false;
          enableLogDetails = true;
          sortOrder = "Descending";
          dedupStrategy = "none";
        };
      }
    ];
  };

  systemMetricsDashboard = {
    id = null;
    uid = "system-metrics";
    title = "System Metrics";
    tags = [
      "prometheus"
      "node"
      "vanaheim"
    ];
    timezone = "browser";
    schemaVersion = 38;
    version = 1;
    refresh = "30s";
    time = {
      from = "now-1h";
      to = "now";
    };

    panels = [
      # --- CPU usage ---
      {
        id = 1;
        type = "timeseries";
        title = "CPU Usage %";
        gridPos = {
          h = 8;
          w = 12;
          x = 0;
          y = 0;
        };
        datasource = {
          type = "prometheus";
          uid = prometheusUid;
        };
        targets = [
          {
            datasource = {
              type = "prometheus";
              uid = prometheusUid;
            };
            expr = "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)";
            legendFormat = "CPU";
            refId = "A";
          }
        ];
        fieldConfig = {
          defaults = {
            unit = "percent";
            min = 0;
            max = 100;
            custom = {
              drawStyle = "line";
              lineInterpolation = "linear";
              fillOpacity = 10;
            };
          };
          overrides = [ ];
        };
        options = {
          tooltip = {
            mode = "single";
          };
          legend = {
            displayMode = "list";
            placement = "bottom";
          };
        };
      }

      # --- Memory usage ---
      {
        id = 2;
        type = "timeseries";
        title = "Memory Usage %";
        gridPos = {
          h = 8;
          w = 12;
          x = 12;
          y = 0;
        };
        datasource = {
          type = "prometheus";
          uid = prometheusUid;
        };
        targets = [
          {
            datasource = {
              type = "prometheus";
              uid = prometheusUid;
            };
            expr = "(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100";
            legendFormat = "Memory";
            refId = "A";
          }
        ];
        fieldConfig = {
          defaults = {
            unit = "percent";
            min = 0;
            max = 100;
            custom = {
              drawStyle = "line";
              lineInterpolation = "linear";
              fillOpacity = 10;
            };
          };
          overrides = [ ];
        };
        options = {
          tooltip = {
            mode = "single";
          };
          legend = {
            displayMode = "list";
            placement = "bottom";
          };
        };
      }

      # --- Network I/O ---
      {
        id = 3;
        type = "timeseries";
        title = "Network I/O";
        gridPos = {
          h = 8;
          w = 24;
          x = 0;
          y = 8;
        };
        datasource = {
          type = "prometheus";
          uid = prometheusUid;
        };
        targets = [
          {
            datasource = {
              type = "prometheus";
              uid = prometheusUid;
            };
            expr = "rate(node_network_receive_bytes_total{device!=\"lo\"}[5m])";
            legendFormat = "rx {{device}}";
            refId = "A";
          }
          {
            datasource = {
              type = "prometheus";
              uid = prometheusUid;
            };
            expr = "rate(node_network_transmit_bytes_total{device!=\"lo\"}[5m])";
            legendFormat = "tx {{device}}";
            refId = "B";
          }
        ];
        fieldConfig = {
          defaults = {
            unit = "Bps";
            custom = {
              drawStyle = "line";
              lineInterpolation = "linear";
              fillOpacity = 5;
            };
          };
          overrides = [ ];
        };
        options = {
          tooltip = {
            mode = "multi";
            sort = "desc";
          };
          legend = {
            displayMode = "table";
            placement = "bottom";
            calcs = [
              "mean"
              "max"
            ];
          };
        };
      }

      # --- Disk usage gauge ---
      {
        id = 4;
        type = "gauge";
        title = "Disk Usage";
        gridPos = {
          h = 8;
          w = 12;
          x = 0;
          y = 16;
        };
        datasource = {
          type = "prometheus";
          uid = prometheusUid;
        };
        targets = [
          {
            datasource = {
              type = "prometheus";
              uid = prometheusUid;
            };
            expr = "(1 - node_filesystem_avail_bytes{fstype!~\"tmpfs|overlay\"} / node_filesystem_size_bytes{fstype!~\"tmpfs|overlay\"}) * 100";
            legendFormat = "{{mountpoint}}";
            refId = "A";
            instant = true;
          }
        ];
        fieldConfig = {
          defaults = {
            unit = "percent";
            min = 0;
            max = 100;
            thresholds = {
              mode = "absolute";
              steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "yellow";
                  value = 75;
                }
                {
                  color = "red";
                  value = 90;
                }
              ];
            };
          };
          overrides = [ ];
        };
        options = {
          reduceOptions = {
            calcs = [ "lastNotNull" ];
          };
          orientation = "auto";
          showThresholdLabels = false;
          showThresholdMarkers = true;
        };
      }

      # --- System load ---
      {
        id = 5;
        type = "timeseries";
        title = "System Load";
        gridPos = {
          h = 8;
          w = 12;
          x = 12;
          y = 16;
        };
        datasource = {
          type = "prometheus";
          uid = prometheusUid;
        };
        targets = [
          {
            datasource = {
              type = "prometheus";
              uid = prometheusUid;
            };
            expr = "node_load1";
            legendFormat = "1m";
            refId = "A";
          }
          {
            datasource = {
              type = "prometheus";
              uid = prometheusUid;
            };
            expr = "node_load5";
            legendFormat = "5m";
            refId = "B";
          }
          {
            datasource = {
              type = "prometheus";
              uid = prometheusUid;
            };
            expr = "node_load15";
            legendFormat = "15m";
            refId = "C";
          }
        ];
        fieldConfig = {
          defaults = {
            unit = "short";
            min = 0;
            custom = {
              drawStyle = "line";
              lineInterpolation = "linear";
              fillOpacity = 5;
            };
          };
          overrides = [ ];
        };
        options = {
          tooltip = {
            mode = "multi";
            sort = "desc";
          };
          legend = {
            displayMode = "list";
            placement = "bottom";
          };
        };
      }
    ];
  };

  dashboardsDir = pkgs.runCommand "grafana-dashboards" { } ''
    mkdir $out
    cp ${pkgs.writeText "system-logs.json" (builtins.toJSON systemLogsDashboard)} $out/system-logs.json
    cp ${pkgs.writeText "system-metrics.json" (builtins.toJSON systemMetricsDashboard)} $out/system-metrics.json
  '';
in
{
  options.modules.homelab.grafana = {
    enable = mkEnableOption "Enable The Grafana dashboard";
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      ensureDatabases = [ "grafana" ];
      ensureUsers = [
        {
          name = "grafana";
          ensureDBOwnership = true;
        }
      ];
    };

    services.grafana = {
      enable = true;
      settings = {
        analytics.reporting_enabled = false;
        users.allow_sign_up = false;

        security = {
          secret_key = "super-secret-key-change-in-production";
        };

        server = {
          http_port = 3010;
          http_addr = "127.0.0.1";
        };
      };

      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "Loki";
            uid = lokiUid;
            type = "loki";
            access = "proxy";
            editable = true;
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
          }
          {
            name = "Prometheus";
            uid = prometheusUid;
            type = "prometheus";
            access = "proxy";
            editable = true;
            url = "http://127.0.0.1:9090";
          }
        ];

        dashboards.settings.providers = [
          {
            name = "vanaheim";
            type = "file";
            disableDeletion = true;
            options.path = "${dashboardsDir}";
          }
        ];
      };
    };

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      {
        directory = "/var/lib/grafana";
        user = "grafana";
        group = "grafana";
        mode = "0700";
      }
    ];
  };
}
