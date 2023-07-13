
{ pkgs, ...}:

 { 
    home.file = {
      ".config/waybar/scripts/volumecontrol.sh" = {              # Custom script: Toggle speaker/headset
        source = ./volumecontrol.sh;
        executable = true;
      };
      ".config/waybar/script/sink.sh" = {              # Custom script: Toggle speaker/headset
        text = ''
          #!/bin/sh

          HEAD=$(awk '/ Built-in Audio Analog Stereo/ { print $2 }' <(${pkgs.wireplumber}/bin/wpctl status | grep "*") | sed -n 2p)
          SPEAK=$(awk '/ S10 Bluetooth Speaker/ { print $2 }' <(${pkgs.wireplumber}/bin/wpctl status | grep "*") | head -n 1)

          if [[ $HEAD = "*" ]]; then
            printf "<span font='13'></span>\n"
          elif [[ $SPEAK = "*" ]]; then
            printf "<span font='10'>󰓃</span>\n"
          fi
          exit 0
        '';
        executable = true;
      };
      ".config/waybar/script/switch.sh" = {              # Custom script: Toggle speaker/headset
        text = ''
          #!/bin/sh

          ID1=$(awk '/ Built-in Audio Analog Stereo/ {sub(/.$/,"",$2); print $2 }' <(${pkgs.wireplumber}/bin/wpctl status) | head -n 1)
          ID2=$(awk '/ S10 Bluetooth Speaker/ {sub(/.$/,"",$2); print $2 }' <(${pkgs.wireplumber}/bin/wpctl status) | sed -n 2p)

          HEAD=$(awk '/ Built-in Audio Analog Stereo/ { print $2 }' <(${pkgs.wireplumber}/bin/wpctl status | grep "*") | sed -n 2p)
          SPEAK=$(awk '/ S10 Bluetooth Speaker/ { print $2 }' <(${pkgs.wireplumber}/bin/wpctl status | grep "*") | head -n 1)

          if [[ $HEAD = "*" ]]; then
            ${pkgs.wireplumber}/bin/wpctl set-default $ID2
          elif [[ $SPEAK = "*" ]]; then
            ${pkgs.wireplumber}/bin/wpctl set-default $ID1
          fi
          exit 0
        '';
        executable = true;
      };
      ".config/waybar/script/ds4.sh" = {              # Custom script: Dualshock battery indicator
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
      ".config/waybar/script/hid.sh" = {              # Custom script: Dualshock battery indicator
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
