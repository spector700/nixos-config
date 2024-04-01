{ pkgs, ... }:
{
  theme.wallpaper = ../../home-modules/nick/themes/wallpaper;

  # Hyprland
  wayland.windowManager.hyprland = {
    settings = {
      exec-once = [
        "sleep 5 && ${pkgs.openrgb}/bin/openrgb --profile iceie"
      ];
    };
  };
}
