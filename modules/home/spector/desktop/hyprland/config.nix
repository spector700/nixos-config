{
  config,
  osConfig,
  pkgs,
  ...
}:
let

  inherit (osConfig.modules.display) monitors;

  pointer = config.home.pointerCursor;
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
    ];

    windowrulev2 = [
      # make Firefox/Zen PiP window floating and sticky
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"

      # Force Screen tearing
      "immediate, class:^(steam_app_[0-9]*)$"

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
      "rounding 0, xwayland:1"
      "center, title:^(Confirm Exit|Open Project|win424|win201|splash)$"
      "size 640 400, title:^(splash)$"

      # Fix steam menus
      "stayfocused, title:^()$,class:^(steam)$"
      "minsize 1 1, title:^()$,class:^(steam)$"

      # Opacity
      "opacity 0.94 0.94,class:^(kitty|thunar|code(.*))$"
    ];

    exec-once = [
      "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
      "koshi"
      "wl-paste --watch cliphist store"
      "${pkgs.wlsunset}/bin/wlsunset -l 32.7 -L -96.9"
      "sleep 8 && ${pkgs.vesktop}/bin/vesktop"
      "spotify"
      # "${pkgs.nextcloud-client}/bin/nextcloud --background"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 1;
      allow_tearing = true;
    };

    # Fix the cursor lagging on nvidia
    cursor = {
      no_hardware_cursors = true;
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

      shadow_offset = "0 2";
      shadow_range = 20;
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
    gestures = {
      workspace_swipe = true;
      workspace_swipe_forever = true;
    };

    dwindle = {
      # keep floating dimentions while tiling
      pseudotile = true;
      preserve_split = true;
      special_scale_factor = 0.9; # restore old special workspace behaviour
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
      # explicit_sync_kms = 0; # Fix screen freezing on nvidia

    };

    # fix bad resolution on games
    xwayland.force_zero_scaling = true;
  };
}
