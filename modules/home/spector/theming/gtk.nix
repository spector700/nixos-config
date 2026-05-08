{ pkgs, ... }:
{
  gtk = {
    gtk4.theme = null;
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
}
