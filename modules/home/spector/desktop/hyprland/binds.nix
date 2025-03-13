{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
let
  screenshotarea = "hyprctl keyword animation 'fadeOut,0,8,slow'; ${getExe pkgs.grimblast} --notify copysave area; hyprctl keyword animation 'fadeOut,1,8,slow'";

  lumastart = "${getExe inputs.lumastart.packages.${pkgs.system}.default}";

  # binds $mod + [alt +] {1..10} to [move to] workspace {1..10}
  workspaces = builtins.concatLists (
    builtins.genList (
      x:
      let
        ws =
          let
            c = (x + 1) / 10;
          in
          builtins.toString (x + 1 - (c * 10));
      in
      [
        "$mod, ${ws}, workspace, ${toString (x + 1)}"
        "ALT SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
      ]
    ) 10
  );

  inherit (lib) getExe;
in
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    # Mouse Moveements
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    # Binds
    bind =
      let
        uexec = program: "exec, uwsm app -- ${program}";
      in
      [
        # Compositor
        "$mod SHIFT, R, ${uexec pkgs.hyprland}/bin/hyprctl reload && hyprpanel quit; hyprpanel"
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
        "$mod, T, ${uexec (getExe pkgs.kitty)}"
        "$mod, E, ${uexec (getExe pkgs.kitty)} -e yazi"
        "CTRL SHIFT, Escape, ${uexec (getExe pkgs.kitty)} -e btop"

        # Programs
        "$mod, B, ${uexec (getExe inputs.zen-browser.packages.${pkgs.system}.default)}"
        "$mod SHIFT, E, ${uexec (getExe pkgs.xfce.thunar)}"

        # Launcher
        "$mod, Space, exec, pkill lumastart || ${lumastart}"
        "$mod, V, exec, pkill rofi || ${getExe pkgs.cliphist} list | ${getExe pkgs.rofi} -dmenu -display-columns 2 | ${getExe pkgs.cliphist} decode | wl-copy"

        # lock screen
        "$mod, L, ${uexec (getExe config.programs.hyprlock.package)}"

        # Power menu
        ", XF86PowerOff, exec, hyprpanel -t powermenu"

        # Screenshot
        ", Print, exec, ${screenshotarea}"
      ]
      ++ workspaces;

    bindl = [
      # Media Controls
      ", XF86AudioPlay, exec, ${getExe pkgs.playerctl} play-pause"
      ", XF86AudioNext, exec, ${getExe pkgs.playerctl} next"
      ", XF86AudioPrev, exec, ${getExe pkgs.playerctl} previous"
      # Mute
      ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ];

    bindle = [
      # Volume
      ", XF86AudioRaiseVolume, exec, hyprpanel -r 'audio.speaker.volume += 0.05; indicator.speaker()'"
      ", XF86AudioLowerVolume, exec, hyprpanel -r 'audio.speaker.volume -= 0.05; indicator.speaker()'"
    ];
  };
}
