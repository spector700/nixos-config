{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.homelab.prometheus;
in
{
  options.modules.homelab.prometheus = {
    enable = mkEnableOption "Enable Prometheus metrics collection";
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      port = 9090;
      extraFlags = [ "--storage.tsdb.retention.time=30d" ];

      exporters.node = {
        enable = true;
        port = 9100;
      };

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "localhost:9100" ];
            }
          ];
        }
      ];
    };

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
