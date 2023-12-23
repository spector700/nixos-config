{ pkgs, lib, user, config, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelParams = [
      #For openrgb with gigabyte motherboard
      "acpi_enforce_resources=lax"
    ];
  };
  networking.hostName = "Alfhiem-Nix";

  # Variables for hyprland nvidia
  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      __GL_GSYNC_ALLOWED = "1";
    };
  };

  local.hardware.nvidia.enable = true;

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
