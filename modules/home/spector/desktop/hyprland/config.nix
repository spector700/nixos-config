{
  wayland.windowManager.hyprland = {
    settings = {
      config = {
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
        input = {
          follow_mouse = 1;
          accel_profile = "flat";
          off_window_axis_events = true;
          float_switch_override_focus = false;
          numlock_by_default = true;
          touchpad.natural_scroll = true;
        };
        dwindle = {
          preserve_split = true;
          special_scale_factor = 0.9;
        };
        binds.movefocus_cycles_fullscreen = false;
        misc = {
          disable_autoreload = true;
          disable_hyprland_logo = true;
          focus_on_activate = true;
          exit_window_retains_fullscreen = false;
          enable_swallow = true;
          swallow_regex = "kitty|thunar|wezterm";
          key_press_enables_dpms = true;
          mouse_move_enables_dpms = true;
          vrr = 1;
        };
        render.direct_scanout = true;
        xwayland.force_zero_scaling = true;
      };

      animation = [
        {
          leaf = "border";
          enabled = true;
          speed = 2;
          bezier = "default";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 4;
          bezier = "default";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 3;
          bezier = "default";
          style = "popin 80%";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 2;
          bezier = "default";
          style = "slide";
        }
      ];

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
        {
          fingers = 4;
          direction = "pinch";
          action = "fullscreen";
        }
      ];
    };
  };
}
