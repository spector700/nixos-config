{ osConfig, lib, ... }:
let
  inherit (osConfig.modules.display) monitors;
  # rotation is stored as a Hyprlang string like "transform,1" or "".
  # Extract the numeric transform index for the Lua hl.monitor API.
  monitorTransform =
    monitor:
    let
      parts = lib.splitString "," monitor.rotation;
    in
    if monitor.rotation == "" || monitor.rotation == "transform,0" then
      0
    else
      lib.toInt (lib.last parts);
  toRegex = list: "^(${lib.concatStringsSep "|" list})$";
  lowopacity = [
    "bar"
    "calendar"
    "notifications"
    "system-menu"
    "quickshell:bar"
    "quickshell:notifications:overlay"
    "quickshell:osd"
  ];
  highopacity = [
    "vicinae"
    "osd"
    "logout_dialog"
    "quickshell:sidebar"
  ];
  blurred = lowopacity ++ highopacity;
  games = "^(steam_app_.*|lutris_game_class|ffxiv|playnite_game_class|gamescope|chiaki|.*[Ww]ine.*|^Minecraft*)$";
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = map (monitor: {
      output = monitor.name;
      mode = "${monitor.resolution}@${toString monitor.refreshRate}";
      inherit (monitor) position;
      inherit (monitor) scale;
      transform = monitorTransform monitor;
    }) monitors;

    workspace_rule = builtins.concatMap (
      monitor:
      map (workspace: {
        workspace = toString workspace;
        monitor = monitor.name;
      }) monitor.workspaces
    ) monitors;

    layer_rule = [
      {
        match.namespace = "${toRegex blurred}";
        blur = true;
      }
      {
        match.namespace = "^quickshell.*$";
        blur_popups = true;
      }
      {
        match.namespace = toRegex [
          "bar"
          "quickshell:bar"
        ];
        xray = true;
      }
      {
        match.namespace = toRegex (highopacity ++ [ "music" ]);
        ignore_alpha = 0.5;
      }
      {
        match.namespace = toRegex lowopacity;
        ignore_alpha = 0.2;
      }
      {
        match.namespace = toRegex [
          "notifications"
          "quickshell:notifications:overlay"
          "quickshell:notifictaions:panel"
        ];
        no_anim = true;
      }
    ];

    window_rule = [
      {
        match.title = "^(Picture-in-Picture)$";
        float = true;
        pin = true;
      }
      {
        match.class = "^(.*blueman-manager(-wrapped)?|nm-applet|nm-connection-editor)$";
        float = true;
      }
      {
        match.class = games;
        immediate = true;
        fullscreen = true;
        workspace = "8";
        no_anim = true;
        no_blur = true;
        no_shadow = true;
      }
      {
        match.class = ".*";
        suppress_event = "maximize";
      }
      {
        match.title = "^(Steam)$";
        workspace = "8 silent";
      }
      {
        match.title = "^(Lutris)$";
        workspace = "8";
      }
      {
        match.title = "^(.*((d|D)isc|ArmC|WebC)ord.*|vesktop)$";
        workspace = "4 silent";
      }
      {
        match.title = "^(Spotify.*)$";
        workspace = "special:special silent";
      }
      {
        match.title = "^(signal)$";
        workspace = "special:special silent";
      }
      {
        match.class = "^(mpv|.+exe|celluloid)$";
        idle_inhibit = "focus";
      }
      {
        match.class = "^(zen)$";
        match.title = "^(.*YouTube.*)$";
        idle_inhibit = "focus";
      }
      {
        match.class = "^(zen)$";
        idle_inhibit = "fullscreen";
      }
      {
        match.class = "^(gcr-prompter)$";
        dim_around = true;
      }
      {
        match.class = "^(xdg-desktop-portal-gtk)$";
        dim_around = true;
      }
      {
        match.class = "^(polkit-gnome-authentication-agent-1)$";
        dim_around = true;
      }
      {
        match.class = "^(zen)$";
        match.title = "^(File Upload)$";
        dim_around = true;
      }
      {
        match.class = "^(.*jetbrains.*)$";
        match.title = "^(Confirm Exit|Open Project|win424|win201|splash)$";
        center = true;
      }
      {
        match.class = "^(.*jetbrains.*)$";
        match.title = "^(splash)$";
        size = "640 400";
      }
      {
        match.class = "^(kitty|thunar|code(.*))$";
        opacity = "0.94 0.94";
      }
    ];
  };
}
