{ pkgs, ... }:
let
  screenshotarea =
    "hyprctl keyword animation 'fadeOut,0,0,default'; grimblast --notify copysave area; hyprctl keyword animation 'fadeOut,1,4,default'";

  # binds $mod + [alt +] {1..10} to [move to] workspace {1..10}
  workspaces = builtins.concatLists (builtins.genList
    (x:
      let ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "ALT SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]) 10);
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      layerrule = [
        "blur, ^(waybar|swaync-.+|system-menu|anyrun|gtk-layer-shell|osd)$"
        "xray 1, ^(waybar|gtk-layer-shell)$"
        "ignorealpha 0.2, ^(waybar|system-menu|anyrun|gtk-layer-shell|osd)$"
        "ignorealpha 0.5, ^(music|calendar|system-menu|anyrun)$"
      ];

      windowrulev2 = [
        # make Firefox PiP window floating and sticky
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"

        # Force Screen tearing
        "immediate, class:^(gamescope)$"

        # Application in workspaces
        "workspace 8 silent, title:^(Steam)$, title:^(Lutris)$"
        "workspace 4 silent, title:^(.*((d|D)isc|ArmC)ord.*)$"
        "workspace special:spotify silent, title:^(Spotify.*)$"

        # idle inhibit while watching videos
        "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
        "idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$"
        "idleinhibit fullscreen, class:^(firefox)$"

        "dimaround, class:^(org.kde.polkit-kde-authentication-agent-1)"

        # Fix xwayland apps
        "rounding 0, xwayland:1"
        "center, title:^(Confirm Exit|Open Project|win424|win201|splash)$"
        "size 640 400, title:^(splash)$"

        # Fix steam menus
        "stayfocused, title:^()$,class:^(steam)$"
        "minsize 1 1, title:^()$,class:^(steam)$"

        # Opacity
        "opacity 0.94 0.94,class:^(kitty|thunar|code(.*))$"
        "opacity 0.94 0.94,title:^(.*((d|D)isc|ArmC)ord.*)$"
      ];

      # Mouse Moveements
      bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];

      # Binds
      bind = [
        # Compositor
        "$mod SHIFT, R, exec, ${pkgs.hyprland}/bin/hyprctl reload && ~/.config/waybar/scripts/restart.sh"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen,"
        "$mod, G, togglefloating"

        # move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "ALT, Tab, focuscurrentorlast"

        # move window
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # special workspaces
        "$mod, S, togglespecialworkspace, spotify"
        "ALT SHIFT, S, movetoworkspace, special"

        # terminal
        "$mod, T, exec, ${pkgs.kitty}/bin/kitty"
        "$mod, E, exec, ${pkgs.kitty}/bin/kitty -e lf"
        "CTRL SHIFT, Escape, exec, ${pkgs.kitty}/bin/kitty -e btop"

        # Programs
        "$mod, B, exec, ${pkgs.firefox}/bin/firefox"
        "$mod SHIFT, E, exec, ${pkgs.xfce.thunar}/bin/thunar"

        # Launcher
        "$mod, Space, exec, pkill anyrun || anyrun"
        "$mod, V, exec, pkill rofi || ${pkgs.cliphist}/bin/cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"

        # lock screen
        "$mod, L, exec, ${pkgs.swaylock-effects}/bin/swaylock"

        # Screenshot
        ", Print, exec, ${screenshotarea}"
      ] ++ workspaces;

      bindl = [
        # Media Controls
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
        # Mute
        ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ];

      bindle = [
        # Volume
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"
      ];

      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.hyprpaper}/bin/hyprpaper"
        "${pkgs.swaynotificationcenter}/bin/swaync"
        "wl-paste --watch cliphist store"
        "${pkgs.wlsunset}/bin/wlsunset -l 32.7 -L -96.9"
        "${pkgs.blueman}/bin/blueman-applet"
        "spotify"
        "armcord --enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer --ozone-platform=wayland"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 1;
        # "col.active_border" = "rgba(88888888)";
        # "col.inactive_border" = "rgba(00000088)";
        "col.active_border" = "rgba(bb9af7ff) rgba(b4f9f8ff) 45deg";
        "col.inactive_border" = "rgba(565f89cc) rgba(9aa5cecc) 45deg";
        allow_tearing = true;
      };

      decoration = {
        rounding = 16;
        blur = {
          brightness = 1.0;
          contrast = 1.0;
          noise = 2.0e-2;

          passes = 3;
          size = 10;
        };

        shadow_offset = "0 2";
        shadow_range = 20;
        "col.shadow" = "rgba(00000055)";
      };

      animations = {
        animation = [
          "border, 1, 2, default"
          "fade, 1, 4, default"
          "windows, 1, 3, default, popin 80%"
          "workspaces, 1, 2, default, slide"
        ];
      };

      input = {
        # focus change on cursor move
        follow_mouse = 1;
        accel_profile = "flat";
      };

      # touchpad gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
      };

      dwindle = {
        # keep floating dimentions while tiling
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        disable_autoreload = true;
        disable_hyprland_logo = true;
        key_press_enables_dpms = true;
        mouse_move_enables_dpms = true;
        vrr = 1;
      };

      xwayland.force_zero_scaling = true;
    };
  };
}
