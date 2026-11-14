_: {
  flake.aspects = { aspects, ... }: {
    vivo = {
      includes = with aspects; [
        # CORE
        core
        impermanence
        cpu-amd

        # SERVICES
        avahi
        acpid
        upower
        ssh
        sops
        gpg
        bluetooth
        printing
        home-manager
        syncthing
        tailscale
        stylix

        # PROGRAMS
        niri
        dms
        vscode
        thunar
      ];

      nixos = { pkgs, ... }: {

        imports = [
          ./_hardware-configuration.nix
        ];

        networking.hostName = "vivo";

        programs.nix-ld.enable = true;

        boot = {
          kernelPackages = pkgs.linuxPackages_latest;
        };

        services = {
          fprintd.enable = true; # run sudo fprintd-enroll

          power-profiles-daemon.enable = true;
          # Causes audio crackeling
          pipewire.lowLatency.enable = false;

          fwupd.enable = true;

          libinput = {
            enable = true;

            mouse = {
              accelProfile = "flat";
              accelSpeed = "0";
              middleEmulation = false;
            };

            touchpad = {
              naturalScrolling = true;
              tapping = true;
              clickMethod = "clickfinger";
              disableWhileTyping = true;
            };
          };
        };

        modules = {
          boot = {
            enableKernelTweaks = true;
          };

          networking.optimizeTcp = true;

          os = {
            mainUser = "spector";
            autoLogin = true;
          };

          desktop = {
            monitors = [
              {
                name = "eDP-1";
                resolution = "1920x1080";
                position = "auto";
                refreshRate = 60;
                scale = "1.50";
                primary = true;
                workspaces = [
                  1
                  2
                  3
                  4
                  5
                  6
                  7
                  8
                  9
                ];
              }
            ];
          };
        };
      };

      homeManager = { };
    };
  };
}
