_: {
  flake.aspects.graphical = {
    nixos =
      {
        config,
        pkgs,
        lib,
        lib',
        ...
      }:
      let
        inherit (lib)
          mkOption
          types
          ;
        cfg = config.programs;
      in
      {
        options.modules.desktop = {
          isWayland = mkOption {
            type = types.bool;
            default = cfg.hyprland.enable || cfg.niri.enable;
            description = ''
              Whether to enable Wayland exclusive modules, this contains a wariety
              of packages, modules, overlays, XDG portals and so on.
            '';
          };

          # Add the command of each desktop for stuff like greetd
          startCommand = mkOption {
            type = types.str;
            default = "uwsm start hyprland-uwsm.desktop";
          };
        };

        config = {
          hardware.graphics = {
            enable = true;
            # enable32Bit = lib'.isx86Linux pkgs; # if we're on x86 linux, we can support 32 bit
          };

          # Taken from Bazzite at https://github.com/ublue-os/bazzite/blob/17c869dc70eede3f7066a8ad9ed07f46798fa9b3/system_files/deck/shared/usr/lib/udev/rules.d/80-gpu-reset.rules
          services.udev.extraRules = ''
            ACTION=="change", ENV{DEVNAME}=="/dev/dri/card0", ENV{RESET}=="1", ENV{PID}!="0", RUN+="${pkgs.coreutils}/bin/kill -9 %E{PID}"
          '';

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
        };
      };

    homeManager = { pkgs, ... }: {

      home.packages = with pkgs; [
        # Terminal Utils
        fastfetch

        # Video/Audio
        mpv
        loupe
        celluloid
        pwvucontrol

        signal-desktop
        obsidian
      ];
    };
  };
}
