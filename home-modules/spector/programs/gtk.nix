{ pkgs, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 20;
  };

  gtk = {
    enable = true;
    theme = {
      # name = "Catppuccin-Mocha-Compact-Blue-Dark";
      # package = pkgs.catppuccin-gtk.override {
      #   size = "compact";
      #   accents = [ "blue" ];
      #   variant = "mocha";
      # };
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "lavender";
      };
    };

    font = {
      name = "Inter";
      package = pkgs.google-fonts.override { fonts = [ "Inter" ]; };
      size = 12;
    };
  };
}
