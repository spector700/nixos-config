{ inputs, pkgs, ... }: {
  imports = [ ./hyprland ./swaync ./waybar ./anyrun.nix ./swaylock.nix ];

  home.packages = with pkgs; [
    inputs.hyprland-contrib.packages.${pkgs.system}.grimblast
    wl-clipboard
    wlsunset
    wlr-randr
    cliphist
    hyprpaper
    hyprpicker
  ];

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    ANKI_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    # MOZ_ENABLE_WAYLAND = "1";
  };
}
