#
#  Specific system configuration settings for desktop
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./desktop
#   │        ├─ default.nix *
#   │        └─ hardware-configuration.nix
#   └─ ./modules
#       ├─ ./desktop
#       │   ├─ ./hyprland
#       │   │   └─ default.nix
#       │   └─ ./virtualisation
#       │       └─ default.nix
#       ├─ ./programs
#       │   └─ games.nix
#       └─ ./hardware
#           └─ default.nix
#

{ pkgs, lib, user, config, ... }:

{
  imports =
    [ (import ./hardware-configuration.nix) ] ++
    [ (import ../../modules/programs/games.nix) ] ++
    [ (import ../../modules/programs/thunar.nix) ] ++
    [ (import ../../modules/hyprland/default.nix) ];

  boot = {
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelParams = [
      #For openrgb with gigabyte motherboard
      "acpi_enforce_resources=lax"
      #Nvidia Power Management
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];

  };
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

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    libinput = {
      enable = true;
      #   # disable mouse acceleration
      #   mouse.accelProfile = "flat";
      #   mouse.accelSpeed = "0";
    };
  };

  services = {
    pipewire.lowLatency.enable = true;

    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
  };

  networking = {
    hostName = "Alfhiem-Nix";
    networkmanager.enable = true;
  };

  # Network wait fails with networkmanager
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  hardware = {
    #sane = {
    #  enable = true;
    #  extraBackends = [ pkgs.sane-airscan ];
    # };
    bluetooth.enable = true;
    openrazer = {
      enable = true;
      mouseBatteryNotifier = false;
      users = [ "${user}" ];
    };

    # Udev rules for vial
    keyboard.qmk.enable = true;

    nvidia = {
      modesetting.enable = true;
      # package = config.boot.kernelPackages.nvidiaPackages.production;
      #Fix suspend/resume
      powerManagement.enable = true;

    };
    opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  services = {
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
  };

  programs = {
    seahorse.enable = true;
    direnv = {
      enable = true;
      silent = true;
    };
  };



}
