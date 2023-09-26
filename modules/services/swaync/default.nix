{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swaynotificationcenter
    libnotify
  ];
  home.file = {
    ".config/swaync/style.css" = {
      source = ./style.css;
    };
    ".config/swaync/configSchema.json" = {
      source = ./configSchema.json;
    };
    ".config/swaync/icons" = {
      source = ./icons;
    };
    ".config/swaync/config.json" = {
      text = ''
        {
          "$schema": "~/.config/swaync/configSchema.json",
          "positionX": "right",
          "positionY": "top",
          "layer": "overlay",
          "control-center-layer": "top",
          "layer-shell": true,
          "cssPriority": "application",
          "control-center-margin-top": 16,
          "control-center-margin-bottom": 16,
          "control-center-margin-right": 16,
          "control-center-margin-left": 0,
          "notification-2fa-action": true,
          "notification-inline-replies": false,
          "notification-icon-size": 64,
          "notification-body-image-height": 100,
          "notification-body-image-width": 200,
          "timeout": 4,
          "timeout-low": 4,
          "timeout-critical": 0,
          "fit-to-screen": true,
          "control-center-width": 500,
          "control-center-height": 600,
          "notification-window-width": 500,
          "keyboard-shortcuts": true,
          "image-visibility": "when-available",
          "transition-time": 200,
          "hide-on-clear": false,
          "hide-on-action": true,
          "script-fail-notify": true,
          "scripts": {
          },
          "notification-visibility": {
            "example-name": {
              "state": "muted",
              "urgency": "Low",
              "app-name": "Spotify"
            }
          },
          "widgets": [
            "inhibitors",
            "label",
            "backlight",
            "volume",
            "mpris",
            "title",
            "dnd",
            "notifications",
            "buttons-grid"
          ],
          "widget-config": {
            "inhibitors": {
              "text": "Inhibitors",
              "button-text": "Clear All",
              "clear-all-button": true
            },
            "backlight": {
              "label": " ",
              "device": "intel_backlight",
              "min": 10
            },
            "volume": {
              "label": "󰕾 "
            },
            "title": {
              "text": "Notifications",
              "clear-all-button": true,
              "button-text": "Clear All"
            },
            "dnd": {
              "text": "Do Not Disturb"
            },
            "label": {
              "max-lines": 5,
              "text": "Notification Center"
            },
            "mpris": {
              "image-size": 128,
              "image-radius": 20
            },
            "buttons-grid": {
                "actions": [
                    {
                        "label": "󰐥",
                        "command": "systemctl poweroff"
                    },
                    {
                        "label": "󰜉",
                        "command": "systemctl reboot"
                    },
                    {
                        "label": "󰌾",
                        "command": "swaylock"
                    },
                    {
                        "label": "󰏥",
                        "command": "systemctl suspend"
                    },
                    {
                        "label": "󰕾",
                        "command": "pactl set-sink-mute @DEFAULT_SINK@ toggle"
                    },
                    {
                        "label": "󰍬",
                        "command": "hyprshade toggle bluefilter"
                    }
                ]
            }
          }
        }
      '';
    };
  };

}
