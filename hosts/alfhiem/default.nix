{ pkgs, config, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    #For openrgb with gigabyte motherboard
    kernelParams = [ "acpi_enforce_resources=lax" ];
  };

  networking.hostName = "alfhiem";

  modules = {
    hardware = {
      gpu.type = "nvidia";
      cpu.type = "amd";
    };

    programs.gaming.enable = true;

    env.desktop = "Hyprland";

    system = {
      mainUser = "nick";
      autoLogin = false;
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

  services = {
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
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
