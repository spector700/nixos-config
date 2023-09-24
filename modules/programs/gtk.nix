# GTK config
{ pkgs, ... }: {


  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Original-Classic";
    package = pkgs.bibata-cursors;
    size = 20;
  };


  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Blue-dark";
      package = pkgs.catppuccin-gtk.override {
        size = "compact";
        accents = [ "blue" ];
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "JetBrains Mono Regular";
      size = 12;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
}
