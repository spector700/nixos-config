{ pkgs, ... }:
{
  home.packages = [ pkgs.adw-gtk3 ];

  gtk = {
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
