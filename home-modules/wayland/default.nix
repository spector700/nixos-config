{ inputs, pkgs, ... }: {

  imports = [
    ./hyprland
    ./swaync
    ./waybar
    ./anyrun.nix
    ./swaylock.nix
  ];

  home.packages = with pkgs; [
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    wl-clipboard
    wlsunset
    wlr-randr
    cliphist
    hyprpaper
    hyprpicker
  ];
}
