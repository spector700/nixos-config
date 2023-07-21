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
      monitor=${toString mainMonitor},3440x1440@100,2076x0,1.25,bitdepth,10
      monitor=${toString secondMonitor},highres,0x0,1.85,bitdepth,10
    '' else ''
      monitor=${toString mainMonitor},1920x1080@60,0x0,1
    '';
  monitors = with host;
    if hostName == "Alfhiem-Nix" then ''
      workspace=${toString mainMonitor},1
      workspace=${toString mainMonitor},2
      workspace=${toString mainMonitor},3
      workspace=${toString mainMonitor},4
      workspace=${toString mainMonitor},5
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
    #package = pkgs.hyprland;
    enableNvidiaPatches = true;
    systemdIntegration = true;
    extraConfig = ''

    ${workspaces}
    ${monitors}

    general {
      border_size=2
      gaps_in=5
      gaps_out=5
      col.active_border=rgba(bb9af7ff) rgba(b4f9f8ff) 45deg
      col.inactive_border=rgba(565f89cc) rgba(9aa5cecc) 45deg
      layout=dwindle
    }

    decoration {
      rounding=5
      multisample_edges=true
      #active_opacity=0.93
      #inactive_opacity=0.93
      fullscreen_opacity=1
      blur=true
      blur_new_optimizations = true
      blur_xray = true
      blur_ignore_opacity = true
      drop_shadow = true
      shadow_ignore_window = true
      shadow_offset = 0 5
      shadow_range = 50
      shadow_render_power = 3
      col.shadow = rgba(00000099)
      blurls = waybar
      blurls = lockscreen
    }

    animations {
      enabled=true
      bezier = myBezier,0.1,0.7,0.1,1.05
      animation=fade,1,7,default
      animation=windows,1,7,myBezier
      animation=windowsOut,1,3,default,popin 60%
      animation=windowsMove,1,7,myBezier
    }

    input {
      kb_layout=us
      #kb_options=caps:ctrl_modifier
      follow_mouse=1
      repeat_delay=250
      numlock_by_default=1
      accel_profile=flat
      sensitivity=0
      ${touchpad}
    }

    ${gestures}

    dwindle {
      pseudotile=false
      force_split=2
      preserve_split=true
    }

    misc {
      disable_hyprland_logo=true
      disable_splash_rendering=true
      key_press_enables_dpms=true
      mouse_move_enables_dpms=true
    }

    # use this instead of hidpi patches
    xwayland {
      force_zero_scaling = true
    }

    debug {
      damage_tracking=2
    }

    bindm=SUPER,mouse:272,movewindow
    bindm=SUPER,mouse:273,resizewindow

    bind=SUPER,B,exec,${pkgs.brave}/bin/brave
    bind=SUPER,X,exec,${pkgs.kitty}/bin/kitty
    bind=SUPER,Q,killactive,
    bind=CTRL SHIFT,Escape,exec,${pkgs.btop}/bin/btop
    bind=SUPER,L,exec,${pkgs.swaylock}/bin/swaylock
    bind=SUPER,E,exec,${pkgs.xfce.thunar}/bin/thunar
    bind=SUPER,G,togglefloating,
    bind=SUPER,Space,exec, pkill rofi || ${pkgs.rofi-wayland}/bin/rofi -show drun
    bind=SUPER,V,exec, pkill rofi || ${pkgs.cliphist}/bin/cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy
    bind=SUPER,P,pseudo,
    bind=SUPER,F,fullscreen,
    bind=SUPER,R,forcerendererreload
    bind=SUPERSHIFT,R,exec,${pkgs.hyprland}/bin/hyprctl reload && ~/.config/waybar/scripts/restart.sh
    bind=SUPER,T,exec,${pkgs.neovim}/bin/nvim

    bind=SUPER,left,movefocus,l
    bind=SUPER,right,movefocus,r
    bind=SUPER,up,movefocus,u
    bind=SUPER,down,movefocus,d

    bind=SUPERSHIFT,left,movewindow,l
    bind=SUPERSHIFT,right,movewindow,r
    bind=SUPERSHIFT,up,movewindow,u
    bind=SUPERSHIFT,down,movewindow,d

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
    bind=SUPER,right,workspace,+1
    bind=SUPER,left,workspace,-1

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
    bind=ALTSHIFT,right,movetoworkspace,+1
    bind=ALTSHIFT,left,movetoworkspace,-1

    bind=CTRL,right,resizeactive,20 0
    bind=CTRL,left,resizeactive,-20 0
    bind=CTRL,up,resizeactive,0 -20
    bind=CTRL,down,resizeactive,0 20

    bind=,print,exec,grimblast --notify edit area ~/Pictures/$(date +%Hh_%Mm_%d_%B_%Y).png

    bind=,XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -d 10
    bind=,XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -i 10
    bind=,XF86AudioMute,exec,${pkgs.pamixer}/bin/pamixer -t
    bind=SUPER_L,c,exec,${pkgs.pamixer}/bin/pamixer --default-source -t
    bind=,XF86AudioMicMute,exec,${pkgs.pamixer}/bin/pamixer --default-source -t
    bind=,XF86MonBrightnessDown,exec,${pkgs.light}/bin/light -U 10
    bind=,XF86MonBrightnessUP,exec,${pkgs.light}/bin/light -A 10

    # only allow shadows for floating windows
    windowrulev2 = noshadow, floating:0

    # Opacity 
    windowrulev2 = opacity 0.90 0.90,class:^(Brave-browser)$
    windowrulev2 = opacity 0.80 0.80,class:^(Steam)$
    windowrulev2 = opacity 0.80 0.80,class:^(steam)$
    windowrulev2 = opacity 0.80 0.80,class:^(steamwebhelper)$
    windowrulev2 = opacity 0.80 0.80,class:^(Spotify)$
    windowrulev2 = opacity 0.80 0.80,class:^(Code)$
    windowrulev2 = opacity 0.95 0.95,class:^(kitty)$
    windowrulev2 = opacity 0.90 0.90,class:^(thunar)$
    windowrulev2 = opacity 0.80 0.80,class:^(file-roller)$
    windowrulev2 = opacity 0.80 0.80,class:^(qt5ct)$
    windowrulev2 = opacity 0.80 0.80,class:^(discord)$ #Discord-Electron
    windowrulev2 = opacity 0.90 0.90,class:^(WebCord)$ #WebCord-Electron
    windowrulev2 = opacity 0.90 0.80,class:^(pavucontrol)$
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
    windowrulev2 = workspace 5 silent, title:^(Spotify)$

    # start Discord/WebCord in ws4
    windowrulev2 = workspace 4 silent, title:^(.*(Disc|WebC)ord.*)$

    windowrule=workspace 8 silent,steam$

    #------------#
    # auto start #
    #------------#
    #exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
    exec-once=${pkgs.waybar}/bin/waybar
    exec-once=${pkgs.swaynotificationcenter}/bin/swaync
    exec-once=wl-paste --watch cliphist store
    exec-once=${pkgs.blueman}/bin/blueman-applet
    exec-once=${pkgs.spotify}/bin/spotify
    exec-once=${pkgs.webcord}/bin/webcord
    ${execute}
  '';
  };


  programs.swaylock = {
    enable = true;
    settings = {
      image = "$HOME/.config/wallpaper";
      color = "1f1d2e80";
      font-size = "24";
      #effect-blur= "7x3";
      indicator-idle-visible = false;
      indicator-radius = 200;
      indicator-thickness = 20;
      inside-color = "1f1d2e";
      inside-clear-color = "1f1d2e";
      inside-ver-color = "00000000";
      inside-wrong-color = "1f1d2e";
      key-hl-color = "eb6f92";
      line-color = "1f1d2e";
      line-clear-color = "1f1d2e";
      line-ver-color = "eb6f92";
      line-wrong-color = "000000f0";
      ring-color = "191724";
      ring-clear-color = "9ccfd8";
      ring-ver-color = "eb6f92";
      ring-wrong-color = "1f1d2e";
      text-color = "e0def4";
      text-ver-color = "ffffff";
      text-wrong-color = "ffffff";
      text-caps-lock-color = "";
      show-failed-attempts = true;
    };
  };

}
