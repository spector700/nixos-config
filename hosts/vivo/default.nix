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

  networking.hostName = "vivo";

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # home-manager modules
  home-manager.users.${user}.config = {
    # sops.secrets = {
    #   "keys/ssh/${user}_${config.networking.hostName}" = {
    #     path = "/home/${user}/.ssh/id_spector";
    #   };
    # };

    modules = {
      theme.wallpaper = ../../modules/home/spector/theming/wallpaper;
    };
  };

  modules = {
    roles = {
      desktop.enable = true;
      development.enable = false;
    };

    hardware = {
      cpu.type = "amd";
      # gpu.type = "nvidia";
      sound.enable = true;

      bluetooth.enable = true;
      printing.enable = true;
    };

    display = {
      gpuAcceleration.enable = true;
      desktop.hyprland.enable = true;

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
      # autoLogin = true;
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
