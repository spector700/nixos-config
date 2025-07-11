{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.modules.homelab.pterodactyl;
in
{
  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.wings = {
      image = "ghcr.io/pterodactyl/wings:latest";
      ports = [
        # "9595:443"
        "2022:2022"
      ];

      environment = {
        TZ = "CDT";
        APP_TIMEZONE = "America/Chicago";
        WINGS_UID = "988";
        WINGS_GID = "988";
        WINGS_USERNAME = "pterodactyl";
        TRUSTED_PROXIES = "10.147.18.11/24";
      };

      volumes = [
        "/persist/var/run/docker.sock:/var/run/docker.sock"
        "/persist/var/lib/docker/containers/:/var/lib/docker/containers/"
        "/persist/etc/pterodactyl/:/etc/pterodactyl/"
        "/persist/var/lib/pterodactyl/:/var/lib/pterodactyl/"
        "/persist/var/log/pterodactyl/:/var/log/pterodactyl/"
        "/persist/tmp/pterodactyl/:/tmp/pterodactyl/"
        "/persist/etc/ssl/certs/ca-certificates.crt:/etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt:ro"
      ];

      extraOptions = [
        "-t"
      ];
    };

    networking.firewall.allowedTCPPorts = [
      2022
      25565
      25566
      34197
    ];

    systemd.tmpfiles.settings."10-pterodactyl" = {
      # "/persist/srv/disks/mass-storage/Pterodactyl".d = {
      #   group = "root";
      #   mode = "0755";
      #   user = "root";
      # };
      # "/persist/srv/disks/mass-storage/Pterodactyl/backups".d = {
      #   group = "root";
      #   mode = "0755";
      #   user = "root";
      # };
      "/persist/var/log/pterodactyl".d = {
        group = "root";
        mode = "0755";
        user = "root";
      };
      "/persist/etc/pterodactyl".d = {
        group = "root";
        mode = "0755";
        user = "root";
      };
      "/persist/tmp/pterodactyl".d = {
        group = "root";
        mode = "0755";
        user = "root";
      };
    };
  };
}
