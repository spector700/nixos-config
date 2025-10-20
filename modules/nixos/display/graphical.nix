{
  pkgs,
  lib,
  lib',
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.modules.display;
  inherit (cfg.desktop) isWayland;
in
{
  options.modules.display.gpuAcceleration = {
    enable = mkEnableOption "Enable GPU Acceleration";
  };

  # Enabled if there is a desktop selected
  config = mkMerge [
    (mkIf cfg.gpuAcceleration.enable {
      hardware.graphics = {
        enable = true;
        enable32Bit = lib'.isx86Linux pkgs; # if we're on x86 linux, we can support 32 bit
      };

      # Taken from Bazzite at https://github.com/ublue-os/bazzite/blob/17c869dc70eede3f7066a8ad9ed07f46798fa9b3/system_files/deck/shared/usr/lib/udev/rules.d/80-gpu-reset.rules
      services.udev.extraRules = ''
        ACTION=="change", ENV{DEVNAME}=="/dev/dri/card0", ENV{RESET}=="1", ENV{PID}!="0", RUN+="${pkgs.coreutils}/bin/kill -9 %E{PID}"
      '';
    })

    (mkIf isWayland {
      # Boot logo
      boot.plymouth = {
        enable = true;
        theme = "lone";
        themePackages = [ (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "lone" ]; }) ];
      };

      # make plymouth work with sleep
      powerManagement = {
        powerDownCommands = ''
          ${pkgs.plymouth} --show-splash
        '';
        resumeCommands = ''
          ${pkgs.plymouth} --quit
        '';
      };

      programs = {
        partition-manager.enable = true;
        seahorse.enable = true;
      };
      services.gnome.gnome-keyring.enable = true;

      security.polkit.enable = true;
    })
  ];
}
