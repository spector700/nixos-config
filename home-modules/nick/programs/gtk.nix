# GTK config
{ pkgs, config, ... }: {
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
  };

  gtk = {
    enable = true;
    theme = {
      name =
        if config.theme.name == "light"
        then "adw-gtk3"
        else "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
      # name = "Catppuccin-Mocha-Compact-Blue-Dark";
      # package = pkgs.catppuccin-gtk.override {
      #   size = "compact";
      #   accents = [ "blue" ];
      #   variant = "mocha";
      # };
    };

    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "lavender";
      };
    };

    font = {
      # name = "JetBrains Mono Regular";
      name = "Inter";
      package = pkgs.google-fonts.override { fonts = [ "Inter" ]; };
      size = 12;
    };

    # gtk3.extraConfig = { gtk-application-prefer-dark-theme = true; };
    #
    # gtk4.extraConfig = { gtk-application-prefer-dark-theme = true; };
  };
}
