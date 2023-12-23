{ pkgs, user, ... }: {
  home.file = {
    ".config/waybar/scripts/volumecontrol.sh" = {
      # Custom script: Toggle speaker/headset
      text = ''
        #!/usr/bin/env sh

        # define functions

        print_error() {
          cat <<EOF
        ./volumecontrol.sh -[device] <action>
        ...valid device are...
            i -- [i]nput decive
            o -- [o]utput device
        ...valid actions are...
            i -- <i>ncrease volume [+5]
            d -- <d>ecrease volume [-5]
            m -- <m>ute [x]
        EOF
          exit 1
        }

        notify_vol() {
          vol=$(${pkgs.pamixer}/bin/pamixer "$srce" --get-volume | cat)
          angle="$((((vol + 2) / 5) * 5))"
          ico="$icodir/vol-$angle.svg"
          notify-send -h int:value:"$vol" -h string:synchronous:my-progress "$nsink" -i "$ico" -t 1000 -e
        }

        notify_mute() {
          mute=$(${pkgs.pamixer}/bin/pamixer "$srce" --get-mute | cat)
          if [ "$mute" = "true" ]; then
            notify-send "$nsink" -i "$icodir"/muted-"$dvce".svg -t 2000 -e
          else
            notify-send "$nsink" -i "$icodir"/unmuted-"$dvce".svg -t 2000 -e
          fi
        }

        # set device source

        while getopts io SetSrc; do
          case $SetSrc in
          i)
            nsink=$(${pkgs.pamixer}/bin/pamixer --list-sources | grep "alsa_input." | head -1 | awk -F '" "' '{print $NF}' | sed 's/"//')
            srce="--default-source"
            dvce="mic"
            ;;
          o)
            nsink=$(${pkgs.pamixer}/bin/pamixer --get-default-sink | grep "alsa_output." | awk -F '" "' '{print $NF}' | sed 's/"//')
            srce=""
            dvce="speaker"
            ;;
          *)
            print_error
            ;;
          esac
        done

        if [ $OPTIND -eq 1 ]; then
          print_error
        fi

        # set device action

        shift $((OPTIND - 1))
        step=''${2:-5}
        icodir="$HOME/.config/swaync/icons/vol"

        case $1 in
        i)
          ${pkgs.pamixer}/bin/pamixer "$srce" -i "$step"
          notify_vol
          ;;
        d)
          ${pkgs.pamixer}/bin/pamixer "$srce" -d "$step"
          notify_vol
          ;;
        m)
          ${pkgs.pamixer}/bin/pamixer "$srce" -t
          notify_mute
          ;;
        *) print_error ;;
        esac
      '';
      executable = true;
    };
  };
}
