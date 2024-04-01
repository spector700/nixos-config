{ pkgs, config, ... }:
let
  screenshotarea =
    "hyprctl keyword animation 'fadeOut,0,0,default'; grimblast --notify copysave area; hyprctl keyword animation 'fadeOut,1,4,default'";

  # binds $mod + [alt +] {1..10} to [move to] workspace {1..10}
  workspaces = builtins.concatLists (builtins.genList
    (x:
      let ws = let c = (x + 1) / 10; in builtins.toString (x + 1 - (c * 10));
      in [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "ALT SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]) 10);
in
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # Mouse Moveements
    bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];

    # Binds
    bind = [
      # Compositor
      "$mod SHIFT, R, exec, ${pkgs.hyprland}/bin/hyprctl reload && koshi quit; koshi"
      "$mod, Q, killactive,"
      "$mod, F, fullscreen,"
      "$mod, G, togglefloating"

      # move focus
      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"
      "ALT, Tab, focuscurrentorlast"

      # move window
      "$mod SHIFT, left, movewindow, l"
      "$mod SHIFT, right, movewindow, r"
      "$mod SHIFT, up, movewindow, u"
      "$mod SHIFT, down, movewindow, d"

      # special workspaces
      "$mod, S, togglespecialworkspace, spotify"
      "ALT SHIFT, S, movetoworkspace, special"

      # terminal
      "$mod, T, exec, ${pkgs.kitty}/bin/kitty"
      "$mod, E, exec, ${pkgs.kitty}/bin/kitty -e yazi"
      "CTRL SHIFT, Escape, exec, ${pkgs.kitty}/bin/kitty -e btop"

      # Programs
      "$mod, B, exec, ${pkgs.firefox}/bin/firefox"
      "$mod SHIFT, E, exec, ${pkgs.xfce.thunar}/bin/thunar"

      # Launcher
      "$mod, Space, exec, pkill anyrun || anyrun"
      "$mod, V, exec, pkill rofi || ${pkgs.cliphist}/bin/cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"

      # lock screen
      "$mod, L, exec, ${config.programs.hyprlock.package}/bin/hyprlock"

      # Power menu
      ", XF86PowerOff, exec, koshi -t powermenu"

      # Screenshot
      ", Print, exec, ${screenshotarea}"
    ] ++ workspaces;

    bindl = [
      # Media Controls
      ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
      ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
      ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      # Mute
      ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    bindle = [
      # Volume
      ", XF86AudioRaiseVolume, exec, koshi -r 'audio.speaker.volume += 0.05; indicator.speaker()'"
      ", XF86AudioLowerVolume, exec, koshi -r 'audio.speaker.volume -= 0.05; indicator.speaker()'"

    ];
  };
}
