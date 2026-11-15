_: {
  flake.aspects = { aspects, ... }: {
    vanaheim = {
      includes = with aspects; [
        # CORE
        lvm-btrfs
        core
        impermanence
        cpu-amd

        # SERVICES
        avahi
        ssh
        sops
        gpg
        home-manager
        tailscale

        # HOMELAB
      ];

      nixos =
        {
          inputs,
          config,
          pkgs,
          ...
        }:
        let
          secretsPath = (toString inputs.nix-secrets) + "/sops";

          macAddress = "92:00:06:ed:33:ca";
          networkInterface = "enp1s0";
          ipv6Address = "2a01:4f9:c010:eb77::1";
          gateway = "fe80::1";
        in
        {

          imports = [
            ./_hardware-configuration.nix
          ];

          sops.secrets.ip = {
            sopsFile = "${secretsPath}/${config.networking.hostName}.yaml";
          };

          networking = {
            hostName = "vanaheim";

            interfaces."${networkInterface}" = {
              ipv6.addresses = [
                {
                  address = "${ipv6Address}";
                  prefixLength = 64;
                }
              ];
            };
            defaultGateway6 = {
              address = "${gateway}";
              interface = "${networkInterface}";
            };
          };

          services = {
            # rename the external interface based on the MAC of the interface
            udev.extraRules = ''SUBSYSTEM=="net", ATTR{address}=="${macAddress}", NAME="${networkInterface}"'';

            fail2ban = {
              enable = true;
              bantime = "1h";
              maxretry = 5;
            };
          };

          boot = {
            kernelPackages = pkgs.linuxPackages_latest;
          };

          modules = {
            boot = {
              enableKernelTweaks = true;
            };

            networking.optimizeTcp = true;

            os = {
              mainUser = "spector";
              autoLogin = false;
            };

            disko.disk = "/dev/sda";
          };
        };

      homeManager = {
      };
    };
  };
}
