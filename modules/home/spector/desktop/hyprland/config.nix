{
  wayland.windowManager.hyprland.settings = {

    general = {
      gaps_in = 3;
      gaps_out = 3;
      border_size = 1;
      allow_tearing = true;
    };

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
      sensitivity = -0.8;
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
