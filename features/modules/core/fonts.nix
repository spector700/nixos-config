_: {
  flake.aspects.fonts.nixos =
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
          packages = [
            config.modules.os.font.package

            # normal fonts
            pkgs.noto-fonts
            pkgs.noto-fonts-cjk-sans
            pkgs.roboto
            pkgs.inter

            # emojis / icons
            pkgs.material-icons
            pkgs.material-design-icons
            pkgs.noto-fonts-color-emoji
            pkgs.twemoji-color-font
          ];

          # causes more issues than it solves
          enableDefaultPackages = false;
          fontDir.enable = true;

          fontconfig = {
            enable = true;
            hinting.enable = true;
            antialias = true;
            useEmbeddedBitmaps = true;

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
    };
}
