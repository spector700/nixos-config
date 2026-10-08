{
  pkgs,
  osConfig,
  inputs,
  lib,
  ...
}:
let
  screenshotarea = "hyprctl keyword animation 'fadeOut,0,8,slow'; ${lib.getExe pkgs.grimblast} --notify copysave area; hyprctl keyword animation 'fadeOut,1,8,slow'";
  volume = "${pkgs.wireplumber}/bin/wpctl";
  brightness = "${lib.getExe pkgs.brightnessctl}";
  media = "${lib.getExe pkgs.playerctl}";
  inherit (lib) optionals;

  mod = "SUPER";
  alt = "ALT";

  mkWorkspaceBinds =
    modifier: dispatcher:
    lib.concatMap (
      workspace:
      let
        key = if workspace == 10 then "0" else toString workspace;
        workspace' = toString workspace;
      in
      [ ''hl.bind("${modifier} + ${key}", ${dispatcher workspace'})'' ]
    ) (lib.range 1 10);

  workspaceBinds = lib.concatStringsSep "\n" (
    mkWorkspaceBinds mod (workspace: ''hl.dsp.focus({ workspace = "${workspace}" })'')
    ++ mkWorkspaceBinds "${alt} + SHIFT" (
      workspace: ''hl.dsp.window.move({ workspace = "${workspace}" })''
    )
  );

  laptopBinds = lib.concatStrings (
    optionals osConfig.modules.roles.laptop.enable [
      ''
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${volume} set-volume -l '1.0' @DEFAULT_SINK@ 5%+"), { locked = true })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${volume} set-volume -l '1.0' @DEFAULT_SINK@ 5%-"), { locked = true })
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${brightness} s 5%+"), { locked = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${brightness} s 5%-"), { locked = true })
      ''
    ]
  );
in
{
  wayland.windowManager.hyprland.extraLuaFiles."nix/hyprland" = ''

    -- Gestures (function actions not serializable via settings)
    hl.gesture({ fingers = 4, direction = "left", action = function() hl.dsp.window.move({ monitor = "l" }) end })
    hl.gesture({ fingers = 4, direction = "right", action = function() hl.dsp.window.move({ monitor = "r" }) end })

    -- Mouse binds
    hl.bind("${mod} + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window" })
    hl.bind("${mod} + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

    -- Compositor
    hl.bind("${mod} + Q", hl.dsp.window.close())
    hl.bind("${mod} + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
    hl.bind("${mod} + G", hl.dsp.window.float({ action = "toggle" }))

    -- Move focus
    hl.bind("${mod} + left", hl.dsp.focus({ direction = "l" }))
    hl.bind("${mod} + right", hl.dsp.focus({ direction = "r" }))
    hl.bind("${mod} + up", hl.dsp.focus({ direction = "u" }))
    hl.bind("${mod} + down", hl.dsp.focus({ direction = "d" }))
    hl.bind("${alt} + Tab", hl.dsp.focus({ urgent_or_last = true }))

    -- Move window
    hl.bind("${mod} + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
    hl.bind("${mod} + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
    hl.bind("${mod} + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
    hl.bind("${mod} + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

    -- Special workspaces
    hl.bind("${mod} + S", hl.dsp.workspace.toggle_special("special"))
    hl.bind("${alt} + SHIFT + S", hl.dsp.window.move({ workspace = "special:special" }))

    -- Terminal
    hl.bind("${mod} + T", hl.dsp.exec_cmd("uwsm app -- ${lib.getExe pkgs.kitty}"))
    hl.bind("${mod} + E", hl.dsp.exec_cmd("uwsm app -- ${lib.getExe pkgs.kitty} -e yazi"))
    hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("uwsm app -- ${lib.getExe pkgs.kitty} -e btop"))

    -- Programs
    hl.bind("${mod} + B", hl.dsp.exec_cmd("uwsm app -- ${
      lib.getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    }"))
    hl.bind("${mod} + SHIFT + E", hl.dsp.exec_cmd("uwsm app -- thunar"))

    -- Screenshot
    hl.bind("Print", hl.dsp.exec_cmd("${screenshotarea}"))

    -- Resize
    hl.bind("${mod} + CTRL + UP", hl.dsp.window.resize({ x = 0, y = -20 }), { repeating = true })
    hl.bind("${mod} + CTRL + DOWN", hl.dsp.window.resize({ x = 0, y = 20 }), { repeating = true })
    hl.bind("${mod} + CTRL + LEFT", hl.dsp.window.resize({ x = -20, y = 0 }), { repeating = true })
    hl.bind("${mod} + CTRL + RIGHT", hl.dsp.window.resize({ x = 20, y = 0 }), { repeating = true })

    -- Media
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("${media} play-pause"), { locked = true })
    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("${media} next"), { locked = true })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("${media} previous"), { locked = true })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("${volume} set-mute @DEFAULT_SINK@ toggle"), { locked = true })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("${volume} set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
    ${laptopBinds}

    -- Workspaces
    ${workspaceBinds}
  '';
}
