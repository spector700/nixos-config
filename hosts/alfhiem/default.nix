{ pkgs, user, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      #For openrgb with gigabyte motherboard
      "acpi_enforce_resources=lax"
    ];
  };
  networking.hostName = "alfhiem";

  # qt = {
  #   enable = true;
  #   platformTheme = "gtk2";
  #   style = "gtk2";
  # };

  # Variables for hyprland nvidia
  environment = {
    sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      SDL_VIDEODRIVER = "wayland";
      ANKI_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      WLR_DRM_NO_ATOMIC = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
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
