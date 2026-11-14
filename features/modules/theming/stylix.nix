{ inputs, ... }:
{
  flake.aspects.stylix.homeManager =
    {
      osConfig,
      pkgs,
      ...
    }:
    let
      inherit (osConfig.modules.os) font;
    in
    {
      imports = [ inputs.stylix.homeModules.stylix ];

      home.packages = [ pkgs.nerd-fonts.symbols-only ];

      stylix = {
        enable = true;
        autoEnable = false;
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-city-dark.yaml";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";
        # base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyodark.yaml";
        polarity = "dark";

        targets.dank-material-shell.enable = false;

        cursor = {
          name = "capitaine-cursors-white";
          package = pkgs.capitaine-cursors;
          size = 30;
        };

        # opacity = {
        #   applications = 1.0;
        #   terminal = 0.97;
        #   desktop = 1.0;
        #   popups = 0.8;
        # };

        fonts = {
          sizes = {
            terminal = font.size;
            applications = font.size;
            desktop = 12;
            popups = font.size;
          };

          monospace = {
            inherit (font) package name;
          };

          serif = {
            name = "Source Serif";
            package = pkgs.source-serif;
          };

          sansSerif = {
            name = "Noto Sans";
            package = pkgs.noto-fonts;
          };

          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
        };
      };
    };
}
