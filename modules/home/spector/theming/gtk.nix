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

  # Enforce dark theme across Libadwaita applications natively
  home.sessionVariables = {
    ADW_COLOR_SCHEME = "prefer-dark";
  };
}
