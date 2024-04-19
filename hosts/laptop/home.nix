{ pkgs, ... }:
let
  suspendScript = pkgs.writeShellScript "suspend-script" ''
    ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running
    # only suspend if audio isn't running
    if [ $? == 1 ]; then
      ${pkgs.systemd}/bin/systemctl suspend
    fi
  '';
in
{
  imports = [ ../../home-modules/wayland ];

  # Wallpaper
  xdg.configFile."wallpaper.png".source = ../../modules/themes/wallpaper;

  # Hyprpaper
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload = ~/.config/wallpaper.png
    wallpaper = ,~/.config/wallpaper.png
  '';

  # Hyprland
  wayland.windowManager.hyprland = {
    settings = {
      bindl = [
        ",XF86MonBrightnessDown,exec,${pkgs.light}/bin/light -U 10"
        ",XF86MonBrightnessUP,exec,${pkgs.light}/bin/light -A 10"
      ];
    };
  };

  # Waybar
  programs.waybar = {
    settings = {
      Main = {
        layer = "top";
        position = "top";
        height = 37;
        gtk-layer-shell = true;

        modules-left = [
          "custom/launcher"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [
          "custom/l_end"
          "clock"
          "custom/r_end"
        ];
        modules-right = [
          "cpu"
          "memory"
          "custom/pad"
          "battery"
          "custom/pad"
          "backlight"
          "custom/pad"
          "pulseaudio"
          "custom/pad"
          "clock"
          "tray"
        ];

        "backlight" = {
          device = "intel_backlight";
          format = "{percent}% <span font='11'>{icon}</span>";
          format-icons = [
            ""
            ""
          ];
          on-scroll-down = "${pkgs.light}/bin/light -U 5";
          on-scroll-up = "${pkgs.light}/bin/light -A 5";
        };
        "battery" = {
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% <span font='11'>{icon}</span>";
          format-charging = "{capacity}% <span font='11'></span>";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          max-length = 25;
        };
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
    timeouts = [
      {
        timeout = 400;
        command = suspendScript.outPath;
      }
    ];
  };
}
