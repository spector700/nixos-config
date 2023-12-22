{ pkgs, user, ... }:

{
  imports = [ ./volumecontrol.nix ];

  home.file = {
    ".config/waybar/scripts/restart.sh" = {
      text = ''
        #!/bin/sh
        pkill waybar
        waybar >/dev/null 2>&1 &
      '';
      executable = true;
    };
    ".config/waybar/scripts/ds4.sh" = {
      # Custom script: Dualshock battery indicator
      text = ''
        #!/bin/sh

        FILE=/sys/class/power_supply/sony_controller_battery_e8:47:3a:05:c0:2b/capacity
        FILE2=/sys/class/power_supply/ps-controller-battery-e8:47:3a:05:c0:2b/capacity

        if [[ -f $FILE ]] then
          DS4BATT=$(cat $FILE)
          printf "<span font='13'>󰊴</span> $DS4BATT%%\n"
        elif [[ -f $FILE2 ]] then
          DS4BATT=$(cat $FILE2)
          printf "<span font='13'>󰊴</span> $DS4BATT%%\n"
        else
          printf "\n"
        fi

        exit 0
      '';
      executable = true;
    };
    ".config/waybar/scripts/hid.sh" = {
      # Custom script: Dualshock battery indicator
      text = ''
        #!/bin/sh

        FILE=/sys/class/power_supply/hidpp_battery_0/capacity

        if [[ -f $FILE ]] then
          HIDBATT=$(cat $FILE)
          printf "<span font='13'> 󰍽</span> $HIDBATT%%\n"
        else
          printf "\n"
        fi

        exit 0
      '';
      executable = true;
    };
  };
}
