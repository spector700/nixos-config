{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/sda" ]; })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    #For openrgb with gigabyte motherboard
    kernelParams = [ "acpi_enforce_resources=lax" ];
  };

  networking.hostName = "alfhiem";

  # home-manager modules
  home-manager.users.${config.modules.os.mainUser}.config.modules = {
    theme.wallpaper = ../../modules/home/spector/theming/wallpaper;
  };

  modules = {
    roles = {
      development.enable = true;
      gaming.enable = true;
    };

    hardware = {
      cpu.type = "amd";
      gpu.type = "nvidia";
      sound.enable = true;
      openrgb.enable = true;

      bluetooth.enable = true;
      printing.enable = true;
    };

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

    networking.optomizeTcp = true;

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
      users = [ "${config.modules.os.mainUser}" ];
    };
  };

}
