{
  lib,
  ...
}:

let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./bar
    ./hyprland
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
  ];

  options.modules.desktop = {
    bar = mkOption {
      type =
        with types;
        nullOr (enum [
          "dankMaterialShell"
          "noctalia"
        ]);
      default = null;
      description = "Which bar to use";
    };
  };
}
