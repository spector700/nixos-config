{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.modules.display.desktop;
in
{
  config = mkIf cfg.isWayland {
    environment.variables = {
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      ANKI_WAYLAND = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };
  };
}
