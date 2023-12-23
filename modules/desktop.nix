{ pkgs, lib, ... }: {
  fonts = {
    packages = with pkgs; [
      # icon fonts
      # material-symbols

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      roboto
      (google-fonts.override { fonts = [ "Inter" ]; })

      # nerdfonts
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    ];

    # causes more issues than it solves
    enableDefaultPackages = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Noto Color Emoji" ];
      sansSerif = [ "Inter" "Noto Color Emoji" ];
      monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
      emoji = [ "Noto Color Emoji" ];
    };
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


  security = {
    polkit.enable = true;
    # allow wayland lockers to unlock the screen
    pam.services.swaylock.text = "auth include login";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "gtk" "hyprland" ];
    };

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

}
