#
# System Menu
#

{  pkgs, ... }:

{ 
  home = {
    packages = with pkgs; [
      rofi-wayland
    ];
  };

  home.file = {
    ".config/rofi/config.rasi" = {
      source = ./config.rasi;
    };
    ".config/rofi/powermenu/powermenu-style-2.rasi" = {
      source = ./powermenu-style-2.rasi;
    };
    ".config/rofi/powermenu.sh" = {
      executable = true;
      text = ''
      #!/usr/bin/env bash

      # Current Theme
      dir="$HOME/.config/rofi/powermenu"
      theme='powermenu-style-2'

      # CMDs
      uptime="$(uptime | awk -F' up ' '{sub(/,.*/, "", $2); print $2}')"

      # Options
      shutdown=''
      reboot=''
      lock=''
      suspend=''
      logout=''

      # Rofi CMD
      rofi_cmd() {
        rofi -dmenu \
          -p "Uptime: $uptime" \
          -mesg "Uptime: $uptime" \
          -theme ''${dir}/''${theme}.rasi
      }

      # Pass variables to rofi dmenu
      run_rofi() {
        echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
      }

      # Execute Command
      run_cmd() {
          if [[ $1 == '--shutdown' ]]; then
            systemctl poweroff
          elif [[ $1 == '--reboot' ]]; then
            systemctl reboot
          elif [[ $1 == '--suspend' ]]; then
            mpc -q pause
            amixer set Master mute
            systemctl suspend
          elif [[ $1 == '--logout' ]]; then
            if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
              openbox --exit
            elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
              bspc quit
            elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
              i3-msg exit
            elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
              qdbus org.kde.ksmserver /KSMServer logout 0 0 0
            fi
          fi
          exit 0
      }

     #Actions
      chosen="$(run_rofi)"
      case ''${chosen} in
      $shutdown)
        run_cmd --shutdown
        ;;
      $reboot)
        run_cmd --reboot
        ;;
      $lock)
        if [[ -x '/usr/bin/betterlockscreen' ]]; then
          betterlockscreen -l
        elif [[ -x '/usr/bin/i3lock' ]]; then
          i3lock
        fi
        ;;
      $suspend)
        run_cmd --suspend
        ;;
      $logout)
        run_cmd --logout
        ;;
      esac

      '';
    };
  };
}
