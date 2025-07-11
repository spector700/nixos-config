{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkDefault;
  secretsPath = (builtins.toString inputs.nix-secrets) + "/sops";

  nat-common =
    forward:
    let
      common = forward // {
        loopbackIPs = [ "157.90.126.175" ];
      };
    in
    forwardPort: [
      (common // forwardPort // { proto = "tcp"; })
      (common // forwardPort // { proto = "udp"; })
    ];
  xenon-internal = "10.147.18.10";
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/vda" ]; })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    growPartition = true;
  };

  virtualisation = {
    oci-containers.backend = "docker";

    docker = {
      rootless = {
        enable = true;
        setSocketVariable = true;
      };

      # daemon.settings = {
      #   ipv6 = true;
      #   fixed-cidr-v6 = "2001:db8:1::/64";
      # };
    };
  };

  # users.users.${config.modules.os.mainUser}.extraGroups = [ "docker" ];

  # security.acme = {
  #   defaults.email = "sever@senveon.com";
  #   acceptTerms = true;
  # };

  networking =
    let
      interface = "enp1s0";
    in
    {
      hostName = "vanaheim";
      hosts = {
        "127.0.0.1" = [
          "wings.zepherintersect.com"
        ];
      };
      firewall.allowedTCPPorts = [
        80
        443
        8080
        2022
        27000
        27001
        27002
        27003
        27004
        27005
        27006
        27007
        27008
        27009
        27010
      ];
      # interfaces.${interface}.ipv6.addresses = [
      #   {
      #     address = "2a01:4f8:1c1c:26c9::2";
      #     prefixLength = 64;
      #   }
      # ];
      #
      # defaultGateway6 = {
      #   address = "fe80::1";
      #   inherit interface;
      # };
      #
      # domain = "zepherintersect.com";
      # nat = {
      #   enable = true;
      #   internalInterfaces = [
      #     "enp1s0"
      #     "ztnfaavftl"
      #   ];
      #   externalInterface = "ztnfaavftl";
      #   forwardPorts =
      #     builtins.concatMap
      #       (nat-common {
      #         destination = "${xenon-internal}:2022";
      #         sourcePort = 2022;
      #       })
      #       [
      #         # More entries if needed
      #       ];
      # };
    };

  # No need for fonts on a server
  fonts.fontconfig.enable = mkDefault false;

  modules = {
    roles = {
      server.enable = true;
    };

    os = {
      mainUser = "spector";
      autoLogin = false;
    };

    homelab = {
      # pterodactyl.enable = true;
      pterodactyl = {
        panel = {
          enable = true;
          ssl = true;
          blueprint = {
            enable = true;
            extensions = {
              # "modpack-downloader" = {
              #   name = "modpack-downloader";
              #   version = "1.0.0";
              #   source = "${pterodactyl-addons}/modpack-installer.zip";
              # };
            };
          };
          users.primary = {
            email = "server@senveon.com";
            username = "spector";
            firstName = "Spector";
            lastName = "Senveon";
            passwordFile = pkgs.writeText "admin-password.txt" "adminadmin";
            # passwordFile = config.sops.secrets."passwords/spector".path;
            isAdmin = true;
          };
          nodes = {
            daemonListen = 443;
          };
          locations = {
            va = {
              short = "va";
              long = "vanaheim";
            };
          };

        };
        wings = {
          enable = true;
          settings = {
            api = {
              ssl.enabled = false;
              port = 8080;
            };
            remote = "https://panel.zepherintersect.com";
            fqdn = "wings.zepherintersect.com";
            behindProxy = true;
            ignore_panel_config_updates = false;
          };
        };
      };
    };

    boot = {
      enableKernelTweaks = true;
      impermanence.enable = true;
    };
  };

  security.dhparams = {
    enable = true;
    params.nginx = { };
  };

  services.nginx = {
    enable = true;
    package = pkgs.nginxStable.override { openssl = pkgs.libressl; };
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    sslDhparam = config.security.dhparams.params.nginx.path;
    appendHttpConfig = ''
      limit_req_zone $binary_remote_addr zone=iso_ratelimit:10m rate=1r/m;
      limit_conn_zone $binary_remote_addr zone=iso_connlimit:10m;

      access_log /var/log/nginx/blocked.log combined if=$ratelimited;

      map $request_uri $ratelimited {
        default 0;
        ~\.iso$ $limit_req_status;
      }
    '';
  };

  sops.secrets = {
    "passwords/spector" = {
      sopsFile = "${secretsPath}/shared.yaml";
      mode = "0400";
      owner = "root";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "server@senveon.com";
  };

  services.nginx.virtualHosts."panel.zepherintersect.com" = {
    # useACMEHost = "zepherintersect.com";
    # forceSSL = true;

    root = "${config.modules.homelab.pterodactyl.panel.dataDir}/public";
    locations."/" = {
      index = "index.php";
      tryFiles = "$uri $uri/ /index.php?$query_string";
    };
    locations."~ \\.php$" = {
      extraConfig = ''
        include ${pkgs.nginx}/conf/fastcgi_params;
        fastcgi_pass unix:/run/phpfpm/pterodactyl.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      '';
    };
  };
}
