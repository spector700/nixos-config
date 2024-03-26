{ pkgs, lib, osConfig, ... }:
let
  inherit (lib) mkIf;
  inherit (osConfig) modules;

  cfg = modules.env;
in
{
  imports = [
    ./hyprland
    ./ags.nix
    ./anyrun.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
  ];

  config = mkIf cfg.desktops.hyprland.enable {
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
