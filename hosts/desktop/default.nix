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
      [(import ./hardware-configuration.nix)] ++
      [(import ../../modules/programs/games.nix)] ++
      [(import ../../modules/desktop/hyprland/default.nix)];

    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 5;
         };
         efi.canTouchEfiVariables = true;
         timeout = 1;
       };
       kernelPackages = pkgs.linuxPackages_xanmod_latest;
       kernelParams = [
        "nvidia-drm.modeset=1"
       ];
    };

    services.xserver = {
        videoDrivers = ["nvidia"];

    #  libinput = {
    #    enable = true;
    #    # disable mouse acceleration
    #    mouse.accelProfile = "flat";
    #    mouse.accelSpeed ="0";
    #    };


     };

     services = {
       pipewire.lowLatency.enable = true; 
       };

     networking = {
     	hostName = "Alfhiem-Nix";
      enableIPv6 = false;
     };

    hardware = {
      #sane = {
      #  enable = true;
      #  extraBackends = [ pkgs.sane-airscan ];
      # };
      nvidia = {
          modesetting.enable = true;
       };
      opengl = {
          enable = true;
          driSupport = true;
          driSupport32Bit = true;
        };
     };
      
    services = {
        blueman.enable = true;
     };

 }
