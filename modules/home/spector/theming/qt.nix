{ pkgs, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  home.packages = [
    pkgs.libsForQt5.qt5ct
    pkgs.kdePackages.qt6ct
  ];

}
