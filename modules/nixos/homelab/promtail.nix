{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.homelab.promtail;
in
{
  options.modules.homelab.promtail = {
    enable = mkEnableOption "Enable Promtail log shipper";
  };

  config = mkIf cfg.enable {
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };

        positions = {
          filename = "/var/lib/promtail/positions.yaml";
        };

        clients = [
          {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          }
        ];

        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
          }
        ];
      };
    };

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      {
        directory = "/var/lib/promtail";
        user = "promtail";
        group = "promtail";
        mode = "0750";
      }
    ];
  };
}
