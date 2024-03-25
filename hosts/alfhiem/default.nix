{ pkgs, user, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    #For openrgb with gigabyte motherboard
    kernelParams = [ "acpi_enforce_resources=lax" ];
  };

  networking.hostName = "alfhiem";

  # qt = {
  #   enable = true;
  #   platformTheme = "gtk2";
  #   style = "gtk2";
  # };

  modules = {
    programs.gaming.enable = true;
    env.desktop = "Hyprland";
    system = {
      mainUser = "spector";
      boot.enableKernelTweaks = true;
    };
  };

  local = {
    hardware = {
      gpuAcceleration.enable = true;
      nvidia.enable = true;
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
      users = [ "${user}" ];
    };
  };
}
