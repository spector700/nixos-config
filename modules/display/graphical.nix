{ pkgs, lib, config, ... }:
{
  # Enabled if there is a desktop selected
  config = lib.mkIf (config.modules.display != "none") {
    fonts = {
      packages = with pkgs; [
        # normal fonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        roboto
        # nerdfonts
        (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
      ];
      # causes more issues than it solves
      enableDefaultPackages = false;

      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "JetBrainsMono Nerd Font" ];
          monospace = [ "JetBrainsMono Nerd Font" ];
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

    systemd = {
      user.services.polkit-kde-authentication-agent-1 = {
        description = "polkit-kde-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart =
            "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    services.gnome.gnome-keyring.enable = true;

    security.polkit.enable = true;
  };
}
