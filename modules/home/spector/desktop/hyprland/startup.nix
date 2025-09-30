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
  inherit (lib) getExe optionals;
in
{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
      "wl-paste --watch cliphist store"
      "${getExe pkgs.wlsunset} -l 32.7 -L -96.9"

      "hyprctl dispatch workspace 1"
      "sleep 9 && ${uexec (getExe pkgs.vesktop)}"
      (uexec (getExe config.programs.spicetify.spicedSpotify))
    ]
    ++ optionals osConfig.programs.steam.enable [ (uexec (getExe pkgs.steam)) ];
  };
}
