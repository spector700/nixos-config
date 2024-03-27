{ pkgs, ... }:
let
  mainMonitor = "DP-2";
  secondMonitor = "DP-3";
in
{
  theme.wallpaper = ../../home-modules/nick/themes/wallpaper;

  # Hyprland
  wayland.windowManager.hyprland = {
    settings = {
      monitor = [
        "${mainMonitor}, 3440x1440@100, 1152x420, 1.25"
        "${secondMonitor}, highres,0x0, 1.875, transform,1"
      ];

      workspace = [
        "${toString mainMonitor},1, default:true"
        "${toString mainMonitor},2"
        "${toString mainMonitor},3"
        "${toString secondMonitor},4"
        "${toString secondMonitor},5"
        "${toString secondMonitor},6"
      ];
      exec-once = [
        "sleep 5 && ${pkgs.openrgb}/bin/openrgb --profile iceie"
      ];
    };
  };
}
