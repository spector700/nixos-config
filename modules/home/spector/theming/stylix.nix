{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.theme.stylix;
in
{
  imports = [ inputs.stylix.homeManagerModules.stylix ];

  options.modules.theme.stylix = {
    enable = mkEnableOption "Enable stylix theming";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];

    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";

      image = config.modules.theme.wallpaper;

      cursor = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 20;
      };

      opacity = {
        applications = 1.0;
        terminal = 0.95;
        desktop = 1.0;
        popups = 1.0;
      };

      fonts = {
        sizes = {
          terminal = 12;
          applications = 12;
          desktop = 11;
          popups = 12;
        };

        monospace = {
          package = with pkgs; (nerdfonts.override { fonts = [ "JetBrainsMono" ]; });
          name = "JetBrainsMono Nerd Font";
        };

        serif = {
          name = "Source Serif";
          package = pkgs.source-serif;
        };

        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
        };
      };
    };
  };
}
