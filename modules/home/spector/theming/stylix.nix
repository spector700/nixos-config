{
  inputs,
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  inherit (osConfig.modules.os) font;
  cfg = config.modules.theme.stylix;
in
{
  imports = [ inputs.stylix.homeModules.stylix ];

  options.modules.theme.stylix = {
    enable = mkEnableOption "Enable stylix theming";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.symbols-only
    ];

    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-city-dark.yaml";
      polarity = "dark";

      image = config.modules.theme.wallpaper;

      cursor = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 20;
      };

      opacity = {
        applications = 1.0;
        terminal = 0.97;
        desktop = 1.0;
        popups = 1.0;
      };

      fonts = {
        sizes = {
          terminal = font.size;
          applications = font.size;
          desktop = 11;
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
      };
    };
  };
}
