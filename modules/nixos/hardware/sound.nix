{
  config,
  lib,
  pkgs,
  lib',
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption mkForce;
  cfg = config.modules.hardware.sound;
in
{
  imports = [ inputs.gaming.nixosModules.pipewireLowLatency ];

  options.modules.hardware.sound = {
    enable = mkEnableOption "Enable Sound";
  };

  config = mkIf cfg.enable {
    # able to change scheduling policies, e.g. to SCHED_RR
    # sounds server use RealtimeKit (rtkti) to acquire
    # realtime priority
    security.rtkit.enable = true;

    services = {
      pulseaudio.enable = mkForce false; # disable pulseAudio

      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = lib'.isx86Linux pkgs; # if we're on x86 linux, we can support 32 bit
        };
        pulse.enable = true;
        jack.enable = false;
        lowLatency.enable = true;
      };
    };

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      "/var/lib/pipewire"
    ];
  };
}
