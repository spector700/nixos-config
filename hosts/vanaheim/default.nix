{
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  homelab = {
    host = {
      hostname = config.networking.hostName;
      description = "Hetzner Vanaheim server";
      interface = "enp1s0";
      ip = ipv6Address;
    };
  };

  modules = {
    homelab = {
      grafana.enable = true;
      loki.enable = true;
      alloy = {
        enable = true;
        enableRemoteIngestion = true;
      };
      prometheus = {
        enable = true;
      };
      alertmanager.enable = true;
    };
  };
}
