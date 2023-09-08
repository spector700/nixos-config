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

{ pkgs, lib, user, ... }:

{
  imports =
    [ (import ./hardware-configuration.nix) ] ++
    [ (import ../../modules/programs/games.nix) ] ++
    [ (import ../../modules/programs/thunar.nix) ] ++
    [ (import ../../modules/desktop/hyprland/default.nix) ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
    # network wait-online always fails
    initrd.systemd.network.wait-online.enable = false;
    #kernelPackages = pkgs.linuxPackages_xanmod_latest;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      #"nvidia-drm.modeset=1"
      #For openrgb with gigabyte motherboard
      "acpi_enforce_resources=lax"
    ];
    # Boot logo
    plymouth = {
      enable = true;
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
    #enableIPv6 = false;
  };

  hardware = {
    #sane = {
    #  enable = true;
    #  extraBackends = [ pkgs.sane-airscan ];
    # };
    bluetooth.enable = true;
    openrazer = {
      enable = true;
      users = [ "${user}" ];
    };

    nvidia = {
      modesetting.enable = true;
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
  environment.systemPackages = with pkgs; [
    razergenie
  ];

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
