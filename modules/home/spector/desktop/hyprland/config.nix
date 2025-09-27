{
  osConfig,
  ...
}:
let
  inherit (osConfig.modules.display) monitors;
in
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    monitor = map (
      m:
      let
        resolution = "${m.resolution}@${toString m.refreshRate}";
      in
      "${m.name},${resolution},${m.position},${m.scale},${m.rotation}"
    ) monitors;

    workspace = builtins.concatMap (
      m: map (x: "${toString x},monitor:${m.name}") m.workspaces
    ) monitors;

    layerrule = [
      "blur, ^(lumastart)|(bar)$"
      "xray 1, ^(bar)$"
      "ignorezero, ^(lumastart)$"

      # Quickshell
      "blurpopups, quickshell:.*"
      "blur, quickshell:.*"
      "ignorealpha 0.79, quickshell:.*"
      "animation slide, quickshell:bar"
      "animation slide bottom, quickshell:cheatsheet"
      "animation popin 120%, quickshell:screenCorners"
      "noanim, quickshell:lockWindowPusher"
      "animation fade, quickshell:notificationPopup"
      "noanim, quickshell:overview"
      "noanim, quickshell:screenshot"
      "blur, quickshell:session"
      "noanim, quickshell:session"
      "ignorealpha 0, quickshell:session"
      "animation slide right, quickshell:sidebarRight"
      "animation slide left, quickshell:sidebarLeft"
      "animation slide, quickshell:verticalBar"
      "animation slide top, quickshell:wallpaperSelector"

      # Launchers need to be FAST
      "noanim, gtk4-layer-shell"
    ];

    windowrulev2 = [
      # make Firefox/Zen PiP window floating and sticky
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"

      # Force Screen tearing
      # "immediate, class:^(steam_app_[0-9]*)$"
      # "immediate, initialclass:^(steam_app_)(.*)$"
      "immediate, class:ffxiv"

      # fix fullscreen flashing
      # "suppressevent fullscreen, class:^(steam_app_[0-9]*)$"
      # "suppressevent fullscreen, class:ffxiv"

      # Application in workspaces
      "workspace 8 silent, title:^(Steam)|(Lutris)$"
      "workspace 4 silent, title:^(.*((d|D)isc|ArmC|WebC)ord.*|vesktop)$"
      "workspace special:spotify silent, title:^(Spotify.*)$"

      # idle inhibit while watching videos
      "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
      "idleinhibit focus, class:^(firefox|zen)$, title:^(.*YouTube.*)$"
      "idleinhibit fullscreen, class:^(firefox|zen)$"

      "dimaround, class:^(gcr-prompter)$"
      "dimaround, class:^(xdg-desktop-portal-gtk)$"
      "dimaround, class:^(polkit-gnome-authentication-agent-1)$"

      # Fix xwayland apps
      # "rounding 0, xwayland:1"
      # "center, title:^(Confirm Exit|Open Project|win424|win201|splash)$"
      # "size 640 400, title:^(splash)$"

      # Fix steam menus
      "stayfocused, title:^()$,class:^(steam)$"
      "minsize 1 1, title:^()$,class:^(steam)$"

      # Opacity
      "opacity 0.94 0.94,class:^(kitty|thunar|code(.*))$"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 1;
      allow_tearing = true;
    };

    # Fix broken rotatated cursor
    cursor = {
      no_hardware_cursors = true;
      use_cpu_buffer = 0;
    };

    decoration = {
      rounding = 16;
      blur = {
        brightness = 1.0;
        contrast = 1.0;
        noise = 1.0e-2;

        vibrancy = 0.2;
        vibrancy_darkness = 0.5;

        passes = 4;
        size = 7;

        popups = true;
      };
      shadow = {
        offset = "0 2";
        range = 20;
      };
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
      follow_mouse = 1; # focus change on cursor move
      sensitivity = -0.49;
      accel_profile = "flat";
      off_window_axis_events = true;
    };

    # touchpad gestures
    gesture = [
      "3, horizontal, workspace"
      "4, left, dispatcher, movewindow, mon:-1"
      "4, right, dispatcher, movewindow, mon:+1"
      "4, pinch, fullscreen"
    ];

    dwindle = {
      # keep floating dimensions while tiling
      pseudotile = true;
      preserve_split = true;
      special_scale_factor = 0.9; # restore old special workspace size
    };

    binds = {
      movefocus_cycles_fullscreen = false; # when on fullscreen window, movefocus will cycle fullscreen, if not, will move focus in a direction.
    };

    misc = {
      disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
      disable_hyprland_logo = true;
      focus_on_activate = true; # Whether Hyprland should focus an app that requests to be focused (an activate request)

      enable_swallow = true; # hide windows that spawn other windows
      swallow_regex = "kitty|thunar|wezterm"; # windows for which swallow is applied

      # Turn on screen when sleeping
      key_press_enables_dpms = true;
      mouse_move_enables_dpms = true;
      vrr = 1;
    };

    render = {
      direct_scanout = true;
    };

    # fix bad resolution on games
    xwayland.force_zero_scaling = true;
  };
}
