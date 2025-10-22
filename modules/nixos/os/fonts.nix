{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib.options) mkOption mkPackageOption;
  inherit (lib.types) str int;
in
{
  options.modules.os.font = {
    name = mkOption {
      type = str;
      description = "The name of the font";
      default = "JetBrainsMono Nerd Font";
    };

    package = mkPackageOption pkgs.nerd-fonts "jetbrains-mono" { };

    size = mkOption {
      type = int;
      description = "The size of the font";
      default = 12;
    };
  };

  config = {
    fonts = {
      packages = with pkgs; [
        config.modules.os.font.package

        # normal fonts
        noto-fonts
        noto-fonts-cjk-sans
        roboto
        inter

        # emojis / icons
        material-icons
        material-design-icons
        noto-fonts-color-emoji
        twemoji-color-font
        openmoji-color
        openmoji-black
      ];

      # causes more issues than it solves
      enableDefaultPackages = false;

      fontconfig = {
        enable = true;
        hinting.enable = true;
        antialias = true;

        defaultFonts =
          let
            dfonts = [
              config.modules.os.font.name
              "Symbols Nerd Font"
              # fallbacks
              "Noto Sans Symbols"
              "Noto Sans Symbols2"
            ];
          in
          {
            serif = dfonts;
            sansSerif = dfonts;
            monospace = dfonts;
            emoji = [
              "Noto Color Emoji"
              "Symbols Nerd Font"
            ];
          };
      };
    };
  };
}
