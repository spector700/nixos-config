{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkMerge mkIf;

  cfg = config.modules.display.desktop;
in
{
  config = mkMerge [
    (mkIf cfg.isWayland {

      environment.variables = {
        NIXOS_OZONE_WL = "1";
        _JAVA_AWT_WM_NONEREPARENTING = "1";
        ANKI_WAYLAND = "1";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        WLR_DRM_NO_ATOMIC = "1";
      };
    })

    # Session for greetd
    (mkIf cfg.hyprland.enable {
      programs.hyprland = {
        enable =
          # assert (
          #   lib.assertMsg (lib.versionOlder config.programs.hyprland.package.version "0.51") "hyprland updated, check orca-slicer."
          # );
          true;

        # needed for setting the wayland environment variables
        withUWSM = true;
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };

      # allow wayland lockers to unlock the screen
      security.pam.services.hyprlock.text = "auth include login";
    })
  ];
}
