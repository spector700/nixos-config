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
      "blur, ^(lumastart|.*bar.*|vicinae)$"
      "xray 1, ^(.*bar.*)$"
      "ignorezero, ^(lumastart)$"

      # Launchers need to be FAST
      "noanim, gtk4-layer-shell"
    ];

    windowrulev2 =
      let
        games = "^(steam_app_.*|lutris_game_class|ffxiv|minigalaxy|playnite_game_class|gamescope|chiaki|.*[Ww]ine.*)$";
      in
      [
        # make Firefox/Zen PiP window floating and sticky
        "float, title:^(Picture-in-Picture)$"
        "pin, title:^(Picture-in-Picture)$"

        "float, class:^(.*blueman-manager(-wrapped)?|nm-applet|nm-connection-editor)$"

        # Force Screen tearing
        "immediate, class:${games}"

        # Ignore maximize requests from apps.
        "suppressevent maximize, class:.*"

        # fix fullscreen flashing
        # "suppressevent fullscreen, class:^(steam_app_[0-9]*)$"
        # "suppressevent fullscreen, class:ffxiv"

        #   Game Launchers
        "workspace 8 silent, title:^(Steam)$"
        "workspace 8, title:^(Lutris)$"

        #   Games no animation, no blur, no shadow
        "workspace 8 class:${games}"
        "noanim, class:${games}"
        "noblur, class:${games}"
        "noshadow, class:${games}"

        "workspace 4 silent, title:^(.*((d|D)isc|ArmC|WebC)ord.*|vesktop)$"
        "workspace special:spotify silent, title:^(Spotify.*)$"
        "workspace special:spotify, title:^(signal)$"

        # idle inhibit while watching videos
        "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
        "idleinhibit focus, class:^(firefox|zen)$, title:^(.*YouTube.*)$"
        "idleinhibit fullscreen, class:^(firefox|zen)$"

        "dimaround, class:^(gcr-prompter)$"
        "dimaround, class:^(xdg-desktop-portal-gtk)$"
        "dimaround, class:^(polkit-gnome-authentication-agent-1)$"

        # Center all floating windows (not xwayland cause popups)
        "center 1, floating:1, xwayland:0"

        # Fix xwayland apps
        "rounding 0, xwayland:1"
        "center, title:^(Confirm Exit|Open Project|win424|win201|splash)$"
        "size 640 400, title:^(splash)$"

        # Opacity
        "opacity 0.94 0.94,class:^(kitty|thunar|code(.*))$"
      ];

    general = {
      gaps_in = 3;
      gaps_out = 3;
      border_size = 1;
      allow_tearing = true;
    };

    # Fix broken rotatated cursor
    # cursor = {
    #   no_hardware_cursors = true;
    #   use_cpu_buffer = 0;
    # };

    decoration = {
      rounding = 16;

      blur = {
        size = 15;
        passes = 2;

        # brightness = 1.0;
        contrast = 1.5;
        noise = 0.08;

        vibrancy = 0.2;
        vibrancy_darkness = 0.5;

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
      sensitivity = -0.7;
      accel_profile = "flat";
      off_window_axis_events = true;
      float_switch_override_focus = false;
      numlock_by_default = true;

      touchpad = {
        natural_scroll = true;
      };
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
      exit_window_retains_fullscreen = false; # if a fullscreen window is closed, the next window will be fullscreened if this is true
      new_window_takes_over_fullscreen = 2;

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

    # fix bad resolution on games with fractional scaling
    xwayland.force_zero_scaling = true;
  };
}
