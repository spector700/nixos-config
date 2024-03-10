{ pkgs, ... }: {

  imports = [
    ./hyprland
    ./ags.nix
    ./anyrun.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
  ];

  home.packages = with pkgs; [
    grimblast
    wl-clipboard
    wlsunset
    wlr-randr
    cliphist
  ];
}
