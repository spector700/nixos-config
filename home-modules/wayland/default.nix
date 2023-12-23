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

  # Create tray target
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };
}
