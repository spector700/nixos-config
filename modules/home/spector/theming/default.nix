{ lib, ... }:
{
  imports = [
    ./gtk.nix
    ./qt.nix
    ./stylix.nix
  ];

  options.modules.theme = {
    wallpaper = lib.mkOption {
      description = ''
        Location of the wallpaper to use throughout the system.
      '';
      type = lib.types.path;
      default = ./wallpaper;
      example = lib.literalExample "./wallpaper.png";
    };
  };
}
