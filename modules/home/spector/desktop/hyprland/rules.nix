{ osConfig, lib, ... }:
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

    # layer rules
    layerrule =
      let
        toRegex =
          list:
          let
            elements = lib.concatStringsSep "|" list;
          in
          "match:namespace ^(${elements})$";

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

        blurred = lib.concatLists [
          lowopacity
          highopacity
        ];
      in
      [
        "${toRegex blurred}, blur true"
        "match:namespace ^quickshell.*$, blur_popups true"
        "${
          toRegex [
            "bar"
            "quickshell:bar"
          ]
        }, xray true"
        "${toRegex (highopacity ++ [ "music" ])}, ignore_alpha 0.5"
        "${toRegex lowopacity}, ignore_alpha 0.2"
        "${
          toRegex [
            "notifications"
            "quickshell:notifications:overlay"
            "quickshell:notifictaions:panel"
          ]
        }, no_anim true"
      ];

    windowrule =
      let
        games = "^(steam_app_.*|lutris_game_class|ffxiv|minigalaxy|playnite_game_class|gamescope|chiaki|.*[Ww]ine.*)$";
      in
      [
        # make Firefox/Zen PiP window floating and sticky
        "match:title ^(Picture-in-Picture)$, float on"
        "match:title ^(Picture-in-Picture)$, pin on"

        "match:class ^(.*blueman-manager(-wrapped)?|nm-applet|nm-connection-editor)$, float on"

        # Force Screen tearing
        "match:class ${games}, immediate on"

        "match:class ${games} fullscreen"

        # Ignore maximize requests from apps.
        # "suppressevent maximize, class:.*"

        # fix fullscreen flashing
        # "suppressevent fullscreen, class:^(steam_app_[0-9]*)$"
        # "suppressevent fullscreen, class:ffxiv"

        #   Game Launchers
        "match:title ^(Steam)$, workspace 8 silent"
        "match:title ^(Lutris)$, workspace 8"

        #   Games no animation, no blur, no shadow
        "match:class ${games}, workspace 8"
        "match:class ${games}, noanim on"
        "match:class ${games}, noblur on"
        "match:class ${games}, noshadow on"

        "match:title ^(.*((d|D)isc|ArmC|WebC)ord.*|vesktop)$, workspace 4 silent"
        "match:title ^(Spotify.*)$, workspace special:special silent"
        "match:title ^(signal)$, workspace special:special silent"

        # idle inhibit while watching videos
        "match:class ^(mpv|.+exe|celluloid)$, idle_inhibit focus"
        "match:class ^(zen)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
        "match:class ^(zen)$, idle_inhibit fullscreen"

        "match:class ^(gcr-prompter)$, dim_around on"
        "match:class ^(xdg-desktop-portal-gtk)$, dim_around on"
        "match:class ^(polkit-gnome-authentication-agent-1)$, dim_around on"
        "match:class ^(zen)$, match:title ^(File Upload)$, dim_around on"

        # Center all floating windows (not xwayland cause popups)
        # "center 1, floating:1, xwayland:0"

        # Fix xwayland apps
        # "rounding 0, xwayland:1"
        "match:class ^(.*jetbrains.*)$, match:title ^(Confirm Exit|Open Project|win424|win201|splash)$, center on"
        "match:class ^(.*jetbrains.*)$, match:title ^(splash)$, size 640 400"

        # Opacity
        "match:class ^(kitty|thunar|code(.*))$, opacity 0.94 0.94"
      ];
  };
}
