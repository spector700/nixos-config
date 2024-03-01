{ config, lib, ... }:
let
  cfg = config.local.hardware;
in
{
  options.local.hardware = {
    gpuAcceleration.enable = lib.mkEnableOption "";
    sound.enable = lib.mkEnableOption "";
    nvidia.enable = lib.mkEnableOption "";
    bluetooth.enable = lib.mkEnableOption "";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.gpuAcceleration.enable {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
      };
    })
    (lib.mkIf cfg.sound.enable {
      security.rtkit.enable = true;
      sound.enable = lib.mkForce false; # disable alsa
      hardware.pulseaudio.enable = lib.mkForce false; # disable pulseAudio
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        jack.enable = false;
        # lowLatency.enable = true;
      };
    })
    (lib.mkIf cfg.nvidia.enable {
      hardware = {
        nvidia = {
          modesetting.enable = true;
          # package = config.boot.kernelPackages.nvidiaPackages.production;
          #Fix suspend/resume
          powerManagement.enable = true;
        };
      };
      services.xserver.videoDrivers = [ "nvidia" ];
      # Nvidia Power Management
      boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
    })
    (lib.mkIf cfg.bluetooth.enable {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    })
  ];
}
