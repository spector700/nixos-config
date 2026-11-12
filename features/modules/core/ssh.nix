_: {
  flake.aspects.ssh = {
    nixos =
      {
        lib,
        config,
        pkgs,
        ...
      }:
      let
        inherit (lib) optionalString;

        # Sops needs access to the keys before the persist dirs are even mounted; so
        # just persisting the keys won't work, we must point at /persist
        isPersistence = config.modules.boot.impermanence.enable;
      in
      {
        users.users.${config.modules.os.mainUser}.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTXJzakLW2xSxhfre6KN/0KEg0zabNIKrqT7YcDzMUf spector@alfheim"
        ];

        services.openssh = {
          enable = true; # local: $ ssh <user>@<ip>
          # generating a key:
          #   - $ ssh-keygen   |  ssh-copy-id <ip/domain>  |  ssh-add
          #   - if ssh-add does not work: $ eval `ssh-agent -s` or eval $(ssh-agent)
          # connect: $ sftp <user>@<ip/domain>
          #   or with file browser: sftp://<ip address>
          # commands:
          #   - lpwd & pwd = print (local) parent working directory
          #   - put/get <filename> = send or receive file

          # Change default port
          ports = [ 5010 ];

          hostKeys = [
            {
              path = "${optionalString isPersistence "/persist"}/etc/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
          ];

          settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false; # use ssh keys only

            Banner = toString (
              pkgs.writeText "ssh_banner" ''
                ⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠛⠛⠋⠉⠈⠉⠉⠉⠉⠛⠻⢿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢿⣿⣿⣿⣿
                ⣿⣿⣿⣿⡏⣀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿
                ⣿⣿⣿⢏⣴⣿⣷⠀⠀⠀⠀⠀⢾⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿
                ⣿⣿⣟⣾⣿⡟⠁⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣷⢢⠀⠀⠀⠀⠀⠀⠀⢸⣿
                ⣿⣿⣿⣿⣟⠀⡴⠄⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⣿
                ⣿⣿⣿⠟⠻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠶⢴⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⣿
                ⣿⣁⡀⠀⠀⢰⢠⣦⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿⡄⠀⣴⣶⣿⡄⣿
                ⣿⡋⠀⠀⠀⠎⢸⣿⡆⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⠗⢘⣿⣟⠛⠿⣼
                ⣿⣿⠋⢀⡌⢰⣿⡿⢿⡀⠀⠀⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⡇⠀⢸⣿⣿⣧⢀⣼
                ⣿⣿⣷⢻⠄⠘⠛⠋⠛⠃⠀⠀⠀⠀⠀⢿⣧⠈⠉⠙⠛⠋⠀⠀⠀⣿⣿⣿⣿⣿
                ⣿⣿⣧⠀⠈⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠟⠀⠀⠀⠀⢀⢃⠀⠀⢸⣿⣿⣿⣿
                ⣿⣿⡿⠀⠴⢗⣠⣤⣴⡶⠶⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡸⠀⣿⣿⣿⣿
                ⣿⣿⣿⡀⢠⣾⣿⠏⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠉⠀⣿⣿⣿⣿
                ⣿⣿⣿⣧⠈⢹⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿
                ⣿⣿⣿⣿⡄⠈⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣦⣄⣀⣀⣀⣀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠙⣿⣿⡟⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠁⠀⠀⠹⣿⠃⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⢐⣿⣿⣿⣿⣿⣿⣿⣿⣿
                ⣿⣿⣿⣿⠿⠛⠉⠉⠁⠀⢻⣿⡇⠀⠀⠀⠀⠀⠀⢀⠈⣿⣿⡿⠉⠛⠛⠛⠉⠉
                ⣿⡿⠋⠁⠀⠀⢀⣀⣠⡴⣸⣿⣇⡄⠀⠀⠀⠀⢀⡿⠄⠙⠛⠀⣀⣠⣤⣤⠄⠀

                Connected to ${config.system.name}
              ''
            );
          };
        };

        programs.ssh.knownHosts = builtins.mapAttrs (_: lib.mkForce) {
          # ship github/gitlab/sourcehut host keys to avoid MiM (man in the middle) attacks
          github-ed25519 = {
            hostNames = [ "github.com" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          };
        };
      };

    homeManager =
      {
        self,
        osConfig,
        config,
        ...
      }:
      let
        hostnames = builtins.attrNames self.nixosConfigurations;
        inherit (config.home) homeDirectory;
        user = osConfig.modules.os.mainUser;
      in
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;

          settings = {
            ${builtins.concatStringsSep " " hostnames} = {
              ForwardAgent = true;
              Compression = true;
              ServerAliveInterval = 0;
              ServerAliveCountMax = 3;
              HashKnownHosts = true;
              UserKnownHostsFile = "~/.ssh/known_hosts";
              ControlMaster = "no";
              ControlPath = "~/.ssh/master-%r@%n:%p";
              ControlPersist = "no";
            };

            "github.com" = {
              HostName = "github.com";
              IdentityFile = "${homeDirectory}/.ssh/gitkey";
            };

            "vanaheim" = {
              HostName = "2a01:4f9:c010:eb77::1";
              User = user;
              IdentityFile = "${homeDirectory}/.ssh/id_spector";
            };

            "hermes" = {
              HostName = "192.168.1.109";
              User = user;
              IdentityFile = "${homeDirectory}/.ssh/id_ed25519_hermes";
            };

            "minecraft" = {
              HostName = "192.168.1.106";
              User = "minecraft";
              IdentityFile = "${homeDirectory}/.ssh/gitkey";
            };
          };
        };
      };
  };
}
