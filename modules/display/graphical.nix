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
    })

    (mkIf (cfg != "none") {
      fonts = {
        packages = with pkgs; [
          # normal fonts
          noto-fonts
          noto-fonts-cjk
          roboto
          material-icons
          material-design-icons
          inter

          # emojis
          noto-fonts-color-emoji
          twemoji-color-font
          openmoji-color
          openmoji-black

          # nerdfonts
          (nerdfonts.override {
            fonts = [
              "FiraCode"
              "JetBrainsMono"
            ];
          })
        ];
        # causes more issues than it solves
        enableDefaultPackages = false;

        fontconfig = {
          enable = true;
          defaultFonts = {
            serif = [ "Noto Serif" ];
            sansSerif = [ "JetBrainsMono Nerd Font" ];
            monospace = [ "JetBrainsMono Nerd Font" ];
            emoji = [ "Noto Color Emoji" ];
          };
          hinting.enable = true;
          antialias = true;
        };
      };

      # Boot logo
      boot.plymouth = {
        enable = true;
        theme = "lone";
        themePackages = [ (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "lone" ]; }) ];
      };

      programs = {
        partition-manager.enable = true;
        seahorse.enable = true;
      };

      systemd.user.services.polkit-kde-authentication-agent-1 = {
        description = "polkit-kde-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      services.gnome.gnome-keyring.enable = true;

      security.polkit.enable = true;
    })
  ];
}
