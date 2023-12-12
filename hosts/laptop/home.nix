#
#  Home-manager configuration for desktop
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./laptop
#   │       └─ ./home.nix
#   └─ ./modules
#         └─ ./hyprland
#             └─ home.nix
#

{ pkgs, ... }:
{
  imports = [ ../../modules/hyprland/home.nix ];

  # Hyprland
  wayland.windowManager.hyprland = {
    extraConfig = ''
          monitor=,preferred,auto,1

          workspaces {
              workspace=,1, default:true
              workspace=,2
              workspace=,3
              workspace=,4
              workspace=,5
              workspace=,6
          }

        gestures {
          workspace_swipe=true
          workspace_swipe_fingers=3
          workspace_swipe_distance=100
        }

      input {
        touchpad {
          natural_scroll=true
          middle_button_emulation=true
          tap-to-click=true
        }
      }

        #------------#
        # auto start #
        #------------#
          exec-once=${pkgs.swaybg}/bin/swaybg -m fill -i $HOME/.config/wallpaper
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

        modules-left = [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "custom/l_end" "clock" "custom/r_end" ];
        modules-right = [ "cpu" "memory" "custom/pad" "battery" "custom/pad" "backlight" "custom/pad" "pulseaudio" "custom/pad" "clock" "tray" ];
      };
    };
  };
}
