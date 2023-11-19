#
#  Hyprland Home-manager configuration
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ ./<host>
#   │       └─ home.nix
#   └─ ./modules
#       └─ ./desktop
#           └─ ./hyprland
#               └─ home.nix *
#

{ pkgs, host, ... }:

let
  touchpad = with host;
    if hostName == "laptop" then ''
        touchpad {
          natural_scroll=true
          middle_button_emulation=true
          tap-to-click=true
        }
      }
    '' else "";
  gestures = with host;
    if hostName == "laptop" then ''
      gestures {
        workspace_swipe=true
        workspace_swipe_fingers=3
        workspace_swipe_distance=100
      }
    '' else "";

  workspaces = with host;
    if hostName == "Alfhiem-Nix" then ''
      monitor=${toString mainMonitor},3440x1440@100,1167x420,1.25,bitdepth,10
      monitor=${toString secondMonitor},highres,0x0,1.85,bitdepth,10,transform,1
    '' else ''
      monitor=${toString mainMonitor},1920x1080@60,0x0,1
    '';
  monitors = with host;
    if hostName == "Alfhiem-Nix" then ''
      workspace=${toString mainMonitor},1
      workspace=${toString mainMonitor},2
      workspace=${toString mainMonitor},3
      workspace=${toString secondMonitor},4
      workspace=${toString secondMonitor},5
      workspace=${toString secondMonitor},6
    '' else "";
  execute = with host;
    if hostName == "Alfhiem-Nix" then ''
      exec-once=${pkgs.swaybg}/bin/swaybg -m fill -i $HOME/.config/wallpaper
    '' else "";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # enableNvidiaPatches = true;
    systemd.enable = true;
    extraConfig = ''

    ${workspaces}
    ${monitors}

    env = WLR_DRM_NO_ATOMIC,1
    env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

    general {
      border_size=2
      gaps_in=5
      gaps_out=5
      col.active_border=rgba(bb9af7ff) rgba(b4f9f8ff) 45deg
      col.inactive_border=rgba(565f89cc) rgba(9aa5cecc) 45deg
      layout=dwindle
      allow_tearing = true
    }

    decoration {
      rounding=5
      shadow_offset=0 5
      shadow_range=50
      shadow_render_power=3
      col.shadow=rgba(00000099)
      blurls = ["gtk-layer-shell" "waybar" "lockscreen"];

      blur {
        passes=3
        ignore_opacity=true
      }
    }

     animations {
      enabled = true
      bezier = wind, 0.05, 0.9, 0.1, 1.05
      bezier = winIn, 0.1, 1.1, 0.1, 1.1
      bezier = winOut, 0.3, -0.3, 0, 1
      bezier = liner, 1, 1, 1, 1


      animation = windows, 1, 6, wind, slide
      animation = windowsIn, 1, 6, winIn, slide
      animation = windowsOut, 1, 5, winOut, slide
      animation = windowsMove, 1, 5, wind, slide
      animation = fade, 1, 10, default
      animation = workspaces, 1, 5, wind
    }

    input {
      kb_layout=us
      follow_mouse=1
      numlock_by_default=1
      accel_profile=flat
      sensitivity=0
      ${touchpad}
    }

    ${gestures}

    dwindle {
      force_split=2
      preserve_split=true
    }

    misc {
      disable_autoreload=true
      disable_hyprland_logo=true
      disable_splash_rendering=true
      key_press_enables_dpms=true
      mouse_move_enables_dpms=true
      vrr=1
    }

    # use this instead of hidpi patches
    xwayland {
      force_zero_scaling=true
    }

    bindm=SUPER,mouse:272,movewindow
    bindm=SUPER,mouse:273,resizewindow

    bind=SUPER,B,exec,${pkgs.firefox}/bin/firefox
    bind=SUPER,T,exec,${pkgs.kitty}/bin/kitty
    bind=CTRL SHIFT,Escape,exec,${pkgs.kitty}/bin/kitty -e btop
    bind=SUPER,L,exec,${pkgs.swaylock-effects}/bin/swaylock
    bind=SUPER,E,exec,${pkgs.xfce.thunar}/bin/thunar
    bind=SUPER,Space,exec, pkill anyrun || anyrun
    bind=SUPER,V,exec, pkill rofi || ${pkgs.cliphist}/bin/cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy
    bind=SUPERSHIFT,R,exec,${pkgs.hyprland}/bin/hyprctl reload && ~/.config/waybar/scripts/restart.sh
    bind=SUPER,P,pseudo,
    bind=SUPER,G,togglefloating,
    bind=SUPER,Q,killactive,
    bind=SUPER,F,fullscreen,
    bind=SUPER,R,forcerendererreload

    bind=SUPER,left,movefocus,l
    bind=SUPER,right,movefocus,r
    bind=SUPER,up,movefocus,u
    bind=SUPER,down,movefocus,d

    bind=SUPERSHIFT,left,movewindow,l
    bind=SUPERSHIFT,right,movewindow,r
    bind=SUPERSHIFT,up,movewindow,u
    bind=SUPERSHIFT,down,movewindow,d

  # bind=CTRL,right,resizeactive,20 0
  # bind=CTRL,left,resizeactive,-20 0
  # bind=CTRL,up,resizeactive,0 -20
  # bind=CTRL,down,resizeactive,0 20

    bind=SUPER,1,workspace,1
    bind=SUPER,2,workspace,2
    bind=SUPER,3,workspace,3
    bind=SUPER,4,workspace,4
    bind=SUPER,5,workspace,5
    bind=SUPER,6,workspace,6
    bind=SUPER,7,workspace,7
    bind=SUPER,8,workspace,8
    bind=SUPER,9,workspace,9
    bind=SUPER,0,workspace,10

    bind=SUPER,S,togglespecialworkspace, spotify
    #bind=SUPER,a,exec,notify-send 'Toggled Special Workspace' -e
    bind=SUPER,c,exec,hyprctl dispatch centerwindow

    bind=ALTSHIFT,S,movetoworkspace,special
    bind=ALTSHIFT,1,movetoworkspace,1
    bind=ALTSHIFT,2,movetoworkspace,2
    bind=ALTSHIFT,3,movetoworkspace,3
    bind=ALTSHIFT,4,movetoworkspace,4
    bind=ALTSHIFT,5,movetoworkspace,5
    bind=ALTSHIFT,6,movetoworkspace,6
    bind=ALTSHIFT,7,movetoworkspace,7
    bind=ALTSHIFT,8,movetoworkspace,8
    bind=ALTSHIFT,9,movetoworkspace,9
    bind=ALTSHIFT,0,movetoworkspace,10

    bind=,print,exec,grimblast --notify edit area ~/Pictures/$(date +%Hh_%Mm_%d_%B_%Y).png

    bind=,XF86AudioPlay,exec,${pkgs.playerctl}/bin/playerctl play-pause
    bind=,XF86AudioNext,exec,${pkgs.playerctl}/bin/playerctl next 
    bind=,XF86AudioPrev,exec,${pkgs.playerctl}/bin/playerctl previous 
    bind=,XF86AudioLowerVolume,exec,${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-
    bind=,XF86AudioRaiseVolume,exec,${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+
    bind=,XF86AudioMute,exec,${pkgs.pamixer}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bind=,XF86AudioMicMute,exec,${pkgs.pamixer}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    bind=,XF86MonBrightnessDown,exec,${pkgs.light}/bin/light -U 10
    bind=,XF86MonBrightnessUP,exec,${pkgs.light}/bin/light -A 10

    # only allow shadows for floating windows
    windowrulev2 = noshadow, floating:0

    # Force Screen tearing
    windowrulev2 = immediate, class:^(Minecraft*)$

    # Opacity 
    windowrulev2 = opacity 0.80 0.80,class:^(Steam)$
    windowrulev2 = opacity 0.80 0.80,class:^(steam)$
    windowrulev2 = opacity 0.80 0.80,class:^(steamwebhelper)$
    windowrulev2 = opacity 0.80 0.80,class:^(Spotify)$
    windowrulev2 = opacity 0.80 0.80,class:^(Code)$
    windowrulev2 = opacity 0.88 0.88,class:^(kitty)$
    windowrulev2 = opacity 0.88 0.88,class:^(thunar)$
    windowrulev2 = opacity 0.80 0.80,class:^(file-roller)$
    windowrulev2 = opacity 0.80 0.80,class:^(qt5ct)$
    windowrulev2 = opacity 0.80 0.80,class:^(discord)$ #Discord-Electron
    windowrulev2 = opacity 0.88 0.88,class:^(WebCord)$ #WebCord-Electron
    windowrulev2 = opacity 0.85 0.80,class:^(pavucontrol)$
    windowrulev2 = opacity 0.80 0.70,class:^(org.kde.polkit-kde-authentication-agent-1)$
    windowrulev2 = opacity 0.80 0.80,class:^(org.telegram.desktop)$

    # Position
    windowrulev2 = float,class:^(org.kde.polkit-kde-authentication-agent-1)$
    windowrulev2 = float,class:^(pavucontrol)$
    windowrulev2 = float,title:^(Media viewer)$
    windowrulev2 = float,title:^(Rofi)$
    windowrulev2 = float,title:^(Volume Control)$
    windowrulev2 = float,title:^(Picture-in-Picture)$
    windowrulev2 = float,class:^(Viewnior)$
    windowrulev2 = float,title:^(DevTools)$
    windowrulev2 = float,class:^(file_progress)$
    windowrulev2 = float,class:^(confirm)$
    windowrulev2 = float,class:^(dialog)$
    windowrulev2 = float,class:^(download)$
    windowrulev2 = float,class:^(notification)$
    windowrulev2 = float,class:^(error)$
    windowrulev2 = float,class:^(confirmreset)$
    windowrulev2 = float,title:^(Open File)$
    windowrulev2 = float,title:^(branchdialog)$
    windowrulev2 = float,title:^(Confirm to replace files)
    windowrulev2 = float,title:^(File Operation Progress)

    windowrulev2 = size 800 600,class:^(download)$
    windowrulev2 = size 800 600,title:^(Open File)$
    windowrulev2 = size 800 600,title:^(Save File)$
    windowrule=pin,title:^(Picture-in-Picture)$
    windowrule=move 75% 75% ,title:^(Picture-in-Picture)$
    windowrule=size 24% 24% ,title:^(Picture-in-Picture)$

    # start spotify tiled in ws5
    windowrulev2 = workspace special:spotify silent, title:^(Spotify)$

    # start Discord/WebCord in ws4
    windowrulev2 = workspace 4 silent, title:^(.*(Disc|ArmC)ord.*)$

    windowrule=workspace 8 silent,steam$

    # idle inhibit while watching videos
    windowrulev2 = idleinhibit focus, class:^(mpv|.+exe)$
    windowrulev2 = idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$

    windowrulev2 = idleinhibit fullscreen,class:^(firefox)$
    windowrulev2 = idleinhibit fullscreen,class:^(Brave-browser)$

    layerrule = blur, ^(gtk-layer-shell|anyrun)$
    layerrule = ignorezero, ^(gtk-layer-shell|anyrun)$

    #------------#
    # auto start #
    #------------#
    exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
    exec-once=dbus-update-activation-environment DISPLAY XAUTHORITY WAYLAND_DISPLAY
    exec-once=${pkgs.waybar}/bin/waybar
    exec-once=${pkgs.swaynotificationcenter}/bin/swaync
    exec-once=wl-paste --watch cliphist store
    exec-once=${pkgs.wlsunset}/bin/wlsunset
    exec-once=${pkgs.blueman}/bin/blueman-applet
    exec-once=spotify
    ${execute}
  '';
  };


  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      image = "$HOME/.config/wallpaper";
      effect-blur = "10x2";
      fade-in = 0.2;
      clock = true;
      font-size = "24";
      indicator-idle-visible = true;
      indicator-radius = 200;
      indicator-thickness = 20;

      key-hl-color = "eb6f92";
      separator-color = "00000000";

      inside-color = "00000033";
      inside-clear-color = "ffffff00";
      inside-ver-color = "ffffff00";
      inside-wrong-color = "1f1d2e";

      line-color = "00000000";
      line-clear-color = "ffffffFF";
      line-ver-color = "ffffffFF";
      line-wrong-color = "ffffffFF";

      ring-color = "ffffff";
      ring-clear-color = "ffffff";
      ring-caps-lock-color = "ffffff";
      ring-ver-color = "ffffff";
      ring-wrong-color = "ffffff";

      text-color = "ffffff";
      text-ver-color = "ffffff";
      text-wrong-color = "ffffff";
      text-caps-lock-color = "ffffff";
      show-failed-attempts = true;
    };
  };
}
