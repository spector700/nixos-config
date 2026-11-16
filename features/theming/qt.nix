_: {
  flake.aspects.qt.homeManager =
    { pkgs, ... }:
    {
      qt = {
        enable = true;
        platformTheme.name = "qtct";
      };

      home.packages = with pkgs; [
        libsForQt5.qt5ct
        kdePackages.qt6ct
      ];
    };
}
