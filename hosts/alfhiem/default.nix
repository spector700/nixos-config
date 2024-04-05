{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    #For openrgb with gigabyte motherboard
    kernelParams = [ "acpi_enforce_resources=lax" ];
  };

  networking.hostName = "alfhiem";

  modules = {
    hardware = {
      cpu.type = "amd";
      gpu.type = "nvidia";
      openrgb.enable = true;

      monitors = [
        {
          name = "DP-2";
          resolution = "3440x1440";
          position = "1152x420";
          refreshRate = 100;
          scale = "1.25";
          primary = true;
          workspaces = [ 1 2 3 7 8 9 ];
        }
        {
          name = "DP-3";
          resolution = "3840x2160";
          scale = "1.875";
          rotation = "transform,1";
          workspaces = [ 4 5 6 ];
        }
      ];
    };

    programs.gaming.enable = true;

    env.desktop = "Hyprland";

    system = {
      mainUser = "spector";
      autoLogin = true;

      networking.optomizeTcp = true;

      boot.enableKernelTweaks = true;
    };
  };

  local = {
    hardware = {
      gpuAcceleration.enable = true;
      sound.enable = true;
      bluetooth.enable = true;
    };
    printing.enable = true;
  };


  hardware = {
    # Udev rules for vial
    keyboard.qmk.enable = true;

    openrazer = {
      enable = true;
      mouseBatteryNotifier = false;
      users = [ "${config.modules.system.mainUser}" ];
    };
  };

  # import home.nix for this host
  home-manager.users.${config.modules.system.mainUser} = import ./home.nix;
}
