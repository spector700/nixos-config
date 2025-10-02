{
  pkgs,
  config,
  osConfig,
  inputs,
  lib,
  ...
}:
let
  screenshotarea = "hyprctl keyword animation 'fadeOut,0,8,slow'; ${getExe pkgs.grimblast} --notify copysave area; hyprctl keyword animation 'fadeOut,1,8,slow'";

  lumastart = "${getExe inputs.lumastart.packages.${pkgs.system}.default}";
  volume = "${pkgs.wireplumber}/bin/wpctl";
  brightness = "${getExe pkgs.brightnessctl}";
  media = "${getExe pkgs.playerctl}";

  inherit (config.modules.desktop) bar;
  inherit (lib) optionals mkIf;

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

    bindd = [
      "Super, Tab, Toggle overview, global, quickshell:overviewToggle"
    ];

    # Binds
    bind =
      let
        uexec = program: "exec, uwsm app -- ${program}";
      in
      [
        # Compositor
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

        # Screenshot
        ", Print, exec, ${screenshotarea}"
      ]
      ++ workspaces
      ++ optionals (bar == "hyprpanel") [
        "$mod SHIFT, R, ${uexec pkgs.hyprland}/bin/hyprctl reload && hyprpanel quit; hyprpanel"
        # Power menu
        ", XF86PowerOff, exec, hyprpanel -t powermenu"
      ]
      ++ optionals (bar == "quickshell") [
        "$mod SHIFT, R, ${uexec pkgs.hyprland}/bin/hyprctl reload"
      ];

    bindl = [
      # Media Controls
      ", XF86AudioPlay, exec, ${media} play-pause"
      ", XF86AudioNext, exec, ${media} next"
      ", XF86AudioPrev, exec, ${media} previous"
      # Mute
      ", XF86AudioMute, exec, ${volume} set-mute @DEFAULT_SINK@ toggle"
      ", XF86AudioMicMute, exec, ${volume} set-mute @DEFAULT_SOURCE@ toggle"
    ];

    bindle = mkIf osConfig.modules.roles.laptop.enable [
      # Volume
      ", XF86AudioRaiseVolume, exec, ${volume} set-volume -l '1.0' @DEFAULT_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, ${volume} set-volume -l '1.0' @DEFAULT_SINK@ 5%-"

      # Brightness
      ", XF86MonBrightnessUp, exec, ${brightness} s 5%+"
      ", XF86MonBrightnessDown, exec, ${brightness} s 5%-"
    ];
  };
}
