# polybar
{

  services.polybar = {
    enable = true;
    extraConfig = ''
            [colors]
      background = #1a1b26
      background-alt = #444
      foreground = #dfdfdf
      foreground-alt = #5f5f5f

      primary = #ffb52a
      secondary = #e60053
      power = #f7768e
      alert = #bd2c40

      [bar/main]
      width = 99%
      height = 25pt
      offset-x = .5%
      offset-y = .2%
      dpi-x = 130
      dpi-y = 130

      padding-left = 2
      padding-right = 2

      border-size = 4
      border-color = none

      fixed-center = true

      separator = ""
      module-margin = 1
      module-margin-right = 1

      background = ''${colors.background}
      foreground = ''${colors.foreground}

      font-0 = JetBrainsMonoNerdFont:style=Regular:pixelsize=10;2
      font-1 = Font Awesome 6 Free:style=Regular:pixelsize=10;2
      font-2 = Font Awesome 6 Free Solid:pixelsize=12;2
      font-3 = Font Awesome 6 Brands:pixelsize=12;2

      modules-left = bspwm 
      modules-center = xwindow 
      modules-right = memory alsa network weather time

      cursor-click = pointer
      cursor-scroll = ns-resize

      enable-ipc = true
      wm-restack = bspwm

      tray-position = right
      tray-background = ''${colors.background-alt}
      tray-padding = 5

      [module/tray]
      type = custom/text
      content = "________"
      content-foreground = ''${colors.background-alt}
      content-background = ''${colors.background-alt}

      [module/xwindow]
      type = internal/xwindow
      label = %title:0:60:...%

      [module/bspwm]
      type = internal/bspwm
      label-focused = %icon%
      label-focused-background = ''${colors.background-alt}
      label-focused-padding = 2
      label-occupied = %icon%
      label-occupied-padding = 2
      label-urgent = %index%!
      label-urgent-background = ''${colors.alert}
      label-urgent-padding = 2
      label-empty = %icon%
      label-empty-foreground = ''${colors.foreground-alt}
      label-empty-padding = 2
      ws-icon-0 = 1;
      ws-icon-1 = 2;
      ws-icon-2 = 3;
      ws-icon-3 = 4;
      ws-icon-4 = 5;

      [module/network]
      type = internal/network
      interface = enp5s0
      interval = 3.0
      format-connected = 
      label-connected = %essid%
      format-disconnected = 󰈂 
      format-disconnected-foreground = ''${colors.foreground-alt}

      [module/alsa]
      type = internal/alsa
      format-volume = <label-volume>
      label-volume =   %percentage%%
      label-volume-foreground = ''${root.foreground}
      format-muted-prefix = "  "
      format-muted-foreground = ''${colors.foreground-alt}
      label-muted =  Muted

      click-right = pavucontrol&

      [module/memory]
      type = internal/memory
      interval = 2
      format-prefix = " ﬙ " 
      format-prefix-foreground = ''${colors.red}
      format-background = ''${colors.background}
      format = <label>
      label = %used%

      [module/weather]
      type = custom/script
      exec = "curl -s 'wttr.in/minsk?format=1' | awk '{print substr($0,7);}'"
      interval = 600
      format-prefix-font = 2
      format-prefix = " "
      format-prefix-foreground = ''${colors.primary}

      click-left = "brave https://wttr.in/minsk"

      [module/time]
      type = internal/date
      interval = 3

      date = %H:%M
      date-alt = %m-%d-%y
      label = %date%
      label-foreground = ''${colors.foreground}
      format-prefix = " "
      format-prefix-foreground = ''${colors.Maroon}

      [settings]
      screenchange-reload = true
      #pseudo-transparency = true
    '';
  };
  home.file = {
    ".config/polybar/launch.sh" = {
      text = ''
        #!/usr/bin/env bash

        DIR="$HOME/.config/polybar"
        # Terminate already running bar instances
        pkill polybar

        # Wait until the processes have been shut down
        while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

        # Launch the bar
        polybar -q main -c "$DIR"/config.ini &
      '';
      executable = true;
    };
    ".config/polybar/toggle-polybar.sh" = {
      text = ''
        #!/usr/bin/env bash
        if pgrep -x "polybar" > /dev/null
        then
            pkill polybar
        else
            polybar
        fi
      '';
      executable = true;
    };
  };
}
