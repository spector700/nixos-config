{
  inputs,
  ...
}:
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
}
