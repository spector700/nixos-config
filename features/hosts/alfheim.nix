_: {
  flake.aspects = { aspects, ... }: {
    alfheim = {
      includes = with aspects; [
        hyprland
        ssh
        bluetooth
        printing
        sound
        core
        impermanence
        sops
        cpu-amd
        gpu-nvidia

      ];

      nixos = { pkgs, ... }: {

        networking.hostName = "alfheim";

        programs.nix-ld.enable = true;

        boot = {
          kernelPackages = pkgs.linuxPackages_latest;
          supportedFilesystems = [ "ntfs" ];
          # For building other systems on this system
          binfmt.emulatedSystems = [ "aarch64-linux" ];
        };

        modules = {
          hardware.gpu = "nvidia";

          os = {
            mainUser = "spector";
            autoLogin = true;
          };

          boot = {
            enableKernelTweaks = true;
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

      homeManager = { };
    };
  };
}
