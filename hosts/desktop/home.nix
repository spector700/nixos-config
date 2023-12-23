{ pkgs, lib, ... }:
let
  mainMonitor = "DP-2";
  secondMonitor = "DP-3";
in
{
  # Wallpaper
  xdg.configFile."wallpaper.png".source = ../../modules/themes/wallpaper;

  # Hyprpaper
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.config/wallpaper.png
    wallpaper = ,~/.config/wallpaper.png
  '';

  # Hyprland
  wayland.windowManager.hyprland = {
    extraConfig = ''
        monitor=${mainMonitor}, 3440x1440@100, 1167x420, 1.25, bitdepth,10
        monitor=${secondMonitor}, highres,0x0, 1.85, bitdepth,10 ,transform,1

        workspaces {
            workspace=${toString mainMonitor},1, default:true
            workspace=${toString mainMonitor},2
            workspace=${toString mainMonitor},3
            workspace=${toString secondMonitor},4
            workspace=${toString secondMonitor},5
            workspace=${toString secondMonitor},6
        }

      #------------#
      # auto start #
      #------------#
        exec-once=${pkgs.openrgb}/bin/openrgb --profile iceie
    '';
  };

  # Waybar
  programs.waybar = {
    settings = {
      Main = {
        layer = "top";
        position = "top";
        height = 37;
        gtk-layer-shell = true;
        output = [ "${mainMonitor}" ];

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

      Sec = {
        layer = "top";
        position = "top";
        height = 16;
        output = [ "${secondMonitor}" ];

        modules-left =
          [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "custom/l_end" "clock" "custom/r_end" ];
        modules-right = [
          "custom/l_end"
          "cpu"
          "memory"
          "custom/r_end"
          "custom/l_end"
          "tray"
          "custom/r_end"
          "custom/l_end"
          "network"
          "bluetooth"
          "pulseaudio"
          "pulseaudio#microphone"
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
