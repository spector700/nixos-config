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
  games = "^(steam_app.*|lutris_game_class|ffxiv|playnite_game_class|gamescope|chiaki|.*[Ww]ine.*|^Minecraft*)$";
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = map (monitor: {
      output = monitor.name;
      mode = "${monitor.resolution}@${toString monitor.refreshRate}";
      inherit (monitor) position scale;
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
    ];

    window_rule = [
      {
        match.title = "^(Picture-in-Picture)$";
        float = true;
        pin = true;
      }
      # fix xwayland apps
      {
        match.xwayland = true;
        match.float = true;
        # rounding = 0;
      }
      {
        match.class = "feh|wlogout|file_progress|confirm|dialog|download|notification|error|splash|confirmreset|org.kde.polkit-kde-authentication-agent-1|org.kde.ark|^(wdisplays)$|^(blueman-manager)$|^(nm-connection-editor)$|it.mijorus.smile";
        float = true;
      }
      {
        match.class = games;
        immediate = true;
        fullscreen = true;
        fullscreen_state = "2 2";
        workspace = "8";
        no_anim = true;
        no_blur = true;
        no_shadow = true;
      }
      {
        match.title = "^(Steam|Lutris)$";
        workspace = "8 silent";
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
