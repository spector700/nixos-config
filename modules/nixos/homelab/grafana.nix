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

  # Dashboard JSON defined as a Nix attrset — serialised at build time.
  # Labels shipped by promtail: job="systemd-journal", host=<hostname>, unit=<systemd-unit>
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
        name = "unit";
        label = "Unit";
        type = "query";
        datasource = {
          type = "loki";
          uid = lokiUid;
        };
        definition = "label_values({job=\"systemd-journal\",host=\"vanaheim\"},unit)";
        query = {
          query = "label_values({job=\"systemd-journal\",host=\"vanaheim\"},unit)";
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
            expr = "sum by(unit) (rate({job=\"systemd-journal\",host=\"vanaheim\",unit=~\"$unit\"}[$__rate_interval]))";
            legendFormat = "{{unit}}";
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
            expr = "{job=\"systemd-journal\",host=\"vanaheim\",unit=~\"$unit\"}";
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

  dashboardsDir = pkgs.writeTextDir "system-logs.json" (builtins.toJSON systemLogsDashboard);
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
