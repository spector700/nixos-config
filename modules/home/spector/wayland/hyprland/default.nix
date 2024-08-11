{
  pkgs,
  osConfig,
  config,
  ...
}:
let
  cfg = osConfig.modules.display.monitors;
  pointer = config.home.pointerCursor;
in
{
  imports = [ ./binds.nix ];

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    monitor = map (
      m:
      let
        resolution = "${m.resolution}@${toString m.refreshRate}";
      in
      "${m.name},${resolution},${m.position},${m.scale},${m.rotation}"
    ) cfg;

    workspace = builtins.concatMap (m: map (x: "${toString x},monitor:${m.name}") m.workspaces) cfg;

    layerrule =
      let
        layers = "^(lumastart)$";
      in
      [
        "blur, ${layers}"
        "xray 1, ^(bar)$"
        # "ignorealpha 0.2, ${layers}"
        "ignorezero, ^(layers)$"
        # "ignorealpha 0.5, ^(lumastart)$"
      ];

    windowrulev2 = [
      # make Firefox PiP window floating and sticky
      "float, title:^(Picture-in-Picture)$"
      "pin, title:^(Picture-in-Picture)$"

      # Force Screen tearing
      "immediate, class:^(steam_app.*)$"

      # Application in workspaces
      "workspace 8 silent, title:^(Steam)|(Lutris)$"
      "workspace 4 silent, title:^(.*((d|D)isc|ArmC|WebC)ord.*|vesktop)$"
      "workspace special:spotify silent, title:^(Spotify.*)$"

      # idle inhibit while watching videos
      "idleinhibit focus, class:^(mpv|.+exe|celluloid)$"
      "idleinhibit focus, class:^(firefox)$, title:^(.*YouTube.*)$"
      "idleinhibit fullscreen, class:^(firefox)$"

      "dimaround, class:^(gcr-prompter)$"
      "dimaround, class:^(xdg-desktop-portal-gtk)$"
      "dimaround, class:^(polkit-gnome-authentication-agent-1)$"

      # Fix xwayland apps
      "rounding 0, xwayland:1"
      "center, title:^(Confirm Exit|Open Project|win424|win201|splash)$"
      "size 640 400, title:^(splash)$"

      # Fix steam menus
      "float, title:^(Steam Settings)$"
      # "stayfocused, title:^()$,class:^(steam)$"
      # "minsize 1 1, title:^()$,class:^(steam)$"

      # Opacity
      "opacity 0.94 0.94,class:^(kitty|thunar|code(.*))$"
    ];

    exec-once = [
      "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
      "koshi"
      "${pkgs.hyprpaper}/bin/hyprpaper"
      "wl-paste --watch cliphist store"
      "${pkgs.wlsunset}/bin/wlsunset -l 32.7 -L -96.9"
      "${pkgs.blueman}/bin/blueman-applet"
      "sleep 8 && ${pkgs.vesktop}/bin/vesktop"
      "spotify"
      "nextcloud --background"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 5;
      border_size = 1;
      "col.active_border" = "rgba(48A0E6ff)";
      "col.inactive_border" = "rgba(565f89cc)";
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
      sensitivity = -0.44;
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
      special_scale_factor = 0.9; # restore old special workspace behaviour
    };

    misc = {
      disable_autoreload = true; # autoreload is unnecessary on nixos, because the config is readonly anyway
      disable_hyprland_logo = true;

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

    xwayland.force_zero_scaling = false;
  };
}
