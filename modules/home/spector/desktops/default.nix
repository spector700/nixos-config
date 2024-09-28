{
  inputs,
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;

  cfg = modules.display;
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./hyprland
    ./ags.nix
    ./anyrun.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
  ];

  config = mkIf (cfg.desktop == "Hyprland") {
    home.packages = with pkgs; [
      grimblast
      wl-clipboard
      wlsunset
      wlr-randr
      cliphist
    ];

    wayland.windowManager.hyprland = {
      enable = true;
    };
  };
}
