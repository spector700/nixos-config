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

  systemLogsDashboard = import ./system-logs.nix { inherit lokiUid; };
  systemMetricsDashboard = import ./system-metrics.nix { inherit prometheusUid; };

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
