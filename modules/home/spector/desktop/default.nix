{
  config,
  lib,
  ...
}:

let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./hyprland
    ./ags.nix
    # ./anyrun.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpanel.nix
    ./hyprpaper.nix
    ./quickshell.nix
  ];

  options.modules.desktop = {
    bar = mkOption {
      type =
        with types;
        nullOr (enum [
          "hyprpanel"
          "quickshell"
        ]);
      default = null;
      description = "Which bar to use";
    };
  };
}
