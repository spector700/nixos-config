{ pkgs, lib, ... }:
{
  # Wallpaper
  xdg.configFile."wallpaper.png".source = ../../modules/themes/wallpaper;

  # Hyprpaper
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.config/wallpaper.png
    wallpaper = ,~/.config/wallpaper.png
  '';

  # Waybar
  programs.waybar = {
    settings = {
      Main = {
        layer = "top";
        position = "top";
        height = 37;
        gtk-layer-shell = true;
        # output = [ "${mainMonitor}" ];

        modules-left =
          [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "custom/l_end" "clock" "custom/r_end" ];
        modules-right = [
          "custom/l_end"
          "cpu"
          "memory"
          "custom/r_end"
          "custom/l_end"
          "network"
          "bluetooth"
          "pulseaudio"
          "pulseaudio#microphone"
          "custom/updates"
          "custom/r_end"
          "custom/l_end"
          "tray"
          "custom/r_end"
          "custom/l_end"
          "custom/wallchange"
          "custom/wbar"
          "custom/r_end"
          "custom/notification"
        ];
      };
    };
  };

  # screen idle
  services.swayidle = {
    enable = true;

    events = [
      {
        event = "before-sleep";
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock-effects}/bin/swaylock";
      }
    ];
    timeouts = [{
      timeout = 500;
      command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
    }];
  };
}
