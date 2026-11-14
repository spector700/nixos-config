_: {
  flake.aspects = { aspects, ... }: {
    alfheim = {
      includes = with aspects; [
        # CORE
        core
        impermanence
        cpu-amd
        gpu-nvidia

        # SERVICES
        avahi
        ssh
        sops
        bluetooth
        printing
        home-manager
        gpg
        openrgb
        nextcloud-client
        syncthing
        sunshine
        openrazer
        stylix

        # PROGRAMS
        hyprland
        dms
        gaming
        vscode
        opencode
        codex
        obs
        davinci-resolve
        orcaslicer
      ];

      nixos = { pkgs, ... }: {

        imports = [
          ./_hardware-configuration.nix
        ];

        networking.hostName = "alfheim";

        programs.nix-ld.enable = true;

        boot = {
          kernelPackages = pkgs.linuxPackages_latest;
          supportedFilesystems = [ "ntfs" ];
          # For building other systems on this system
          binfmt.emulatedSystems = [ "aarch64-linux" ];
          # For openrgb to work
          kernelParams = [ "acpi_enforce_resources=lax" ];
        };

        modules = {
          boot = {
            enableKernelTweaks = true;
          };

          networking.optimizeTcp = true;

          hardware.gpu = "nvidia";

          os = {
            mainUser = "spector";
            autoLogin = true;
          };

          desktop = {
            monitors = [
              {
                name = "DP-2";
                resolution = "3440x1440";
                position = "1152x420";
                refreshRate = 100;
                scale = "1.25";
                primary = true;
                workspaces = [
                  1
                  2
                  3
                  7
                  8
                  9
                ];
              }
              {
                name = "DP-3";
                resolution = "3840x2160";
                scale = "1.875";
                refreshRate = 60;
                rotation = "transform,1";
                workspaces = [
                  4
                  5
                  6
                ];
              }
            ];
          };
        };
      };

      homeManager = { pkgs, ... }: {

        home.packages = with pkgs; [
          gimp
          feishin
        ];
      };
    };
  };
}
