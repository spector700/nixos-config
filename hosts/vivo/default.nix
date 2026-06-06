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
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/nvme0n1" ]; })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # For niri
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  networking.hostName = "vivo";

  # home-manager modules
  home-manager.users.${user}.config = {

    modules = {
      desktop = {
        bar = "dankMaterialShell";
      };

      theme = {
        wallpaper = ../../modules/home/spector/theming/wallpaper2.png;
        stylix.enable = false;
      };

      services.nextcloud-client.enable = true;

      programs = {
        spicetify.enable = true;
        zathura.enable = true;
        rofi.enable = true;
        zen.enable = true;
      };
    };
  };

  services = {
    fprintd = {
      enable = true; # run sudo fprintd-enroll
    };

    power-profiles-daemon.enable = true;
    pipewire.lowLatency.enable = false;

    fwupd.enable = true;

    libinput = {
      enable = true;

      # disable mouse acceleration (yes im gamer)
      mouse = {
        accelProfile = "flat";
        accelSpeed = "0";
        middleEmulation = false;
      };

      # touchpad settings
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        clickMethod = "clickfinger";
        disableWhileTyping = true;
      };
    };
  };

  ## NIXOS
  modules = {
    roles = {
      laptop.enable = true;
    };

    networking = {
      tailscale.enable = true;
      optomizeTcp = true;
    };

    hardware = {
      cpu.type = "amd";
      sound.enable = true;

      bluetooth.enable = true;
      printing.enable = true;
    };

    display = {
      gpuAcceleration.enable = true;
      desktop.niri.enable = true;

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
  };
}
