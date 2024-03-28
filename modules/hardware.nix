{ config, lib, inputs, pkgs, lib', ... }:
let
  inherit (lib') isx86Linux;
  cfg = config.local.hardware;
in
{
  imports = [ inputs.gaming.nixosModules.pipewireLowLatency ];

  options.local.hardware = {
    gpuAcceleration.enable = lib.mkEnableOption "";
    sound.enable = lib.mkEnableOption "";
    bluetooth.enable = lib.mkEnableOption "";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.gpuAcceleration.enable {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = isx86Linux pkgs; # if we're on x86 linux, we can support 32 bit
      };
    })
    (lib.mkIf cfg.sound.enable {
      # able to change scheduling policies, e.g. to SCHED_RR
      # sounds server use RealtimeKit (rtkti) to acquire
      # realtime priority
      security.rtkit.enable = true;
      sound.enable = lib.mkForce false; # disable alsa

      hardware.pulseaudio.enable = lib.mkForce false; # disable pulseAudio

      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = isx86Linux pkgs; # if we're on x86 linux, we can support 32 bit
        };
        pulse.enable = true;
        jack.enable = false;
        lowLatency.enable = true;
      };
    })
    (lib.mkIf cfg.bluetooth.enable {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    })
  ];
}
