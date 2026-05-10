{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  uexec = program: "uwsm app -- ${program}";

  pointer = config.home.pointerCursor;
  inherit (config.modules.desktop) bar;
  inherit (lib) getExe optionals;
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      # "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
      "wl-paste --watch cliphist store"
      "hyprctl dispatch workspace 1"
    ]

    ++ optionals (bar != "dankMaterialShell") [
      "${getExe pkgs.wlsunset} -l 32.7 -L -96.9"
    ]

    ++ optionals config.programs.nixcord.vesktop.enable [
      "sleep 9 && ${uexec (getExe config.programs.nixcord.vesktop.package)}"
    ]

    ++ optionals config.modules.programs.spicetify.enable [
      (uexec (getExe config.programs.spicetify.spicedSpotify))
    ]

    ++ optionals osConfig.programs.steam.enable [ (uexec "steam") ];
  };
}
