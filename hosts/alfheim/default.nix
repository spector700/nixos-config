{
  pkgs,
  config,
  inputs,
  ...
}:
let
  user = config.modules.os.mainUser;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    inputs.chaotic.nixosModules.default
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/sda" ]; })
  ];

  boot = {
    # kernelPackages = pkgs.linuxPackages_6_6; # fix Freezing in games
    kernelPackages = pkgs.linuxPackages_latest;
    #For openrgb with gigabyte motherboard
    kernelParams = [ "acpi_enforce_resources=lax" ];
  };

  networking.hostName = "alfheim";

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # home-manager modules
  home-manager.users.${user}.config = {
    sops.secrets = {
      "keys/ssh/${user}_${config.networking.hostName}" = {
        path = "/home/${user}/.ssh/id_spector";
      };
    };

    home.packages = with pkgs; [
      gimp
    ];

    modules = {
      theme = {
        wallpaper = ../../modules/home/spector/theming/wallpaper;
        stylix.enable = true;
      };

      services.nextcloud-client.enable = true;

      programs = {
        spicetify.enable = true;
        zathura.enable = true;
        orca-slicer.enable = true;
        rofi.enable = true;
        brave.enable = true;
        zen.enable = true;
      };
    };
  };

  modules = {
    roles = {
      development.enable = false;
      gaming.enable = true;
      video.enable = true;
    };

    networking = {
      avahi.enable = true;
      optomizeTcp = true;
    };

    hardware = {
      cpu.type = "amd";
      gpu.type = "nvidia";
      sound.enable = true;
      openrgb.enable = true;

      bluetooth.enable = true;
      printing.enable = true;
    };

    homelab = {
      ollama.enable = true;
    };

    services.sunshine.enable = true;

    display = {
      gpuAcceleration.enable = true;
      desktop.hyprland.enable = true;

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

    programs = {
      thunar.enable = true;
    };

    os = {
      mainUser = "spector";
      autoLogin = true;
    };

    boot = {
      enableKernelTweaks = true;
      impermanence.enable = true;
    };
  };

  hardware = {
    # Udev rules for vial
    keyboard.qmk.enable = true;

    openrazer = {
      enable = true;
      batteryNotifier.enable = false;
      users = [ "${user}" ];
    };
  };
}
