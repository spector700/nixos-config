{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkMerge mkIf optionalString;

  cfg = config.modules.display;
in
{
  config = mkMerge [
    (mkIf cfg.isWayland {
      environment.etc."greetd/environments".text = ''
        ${optionalString (cfg.desktop == "Hyprland") "Hyprland"}
        zsh
      '';

      environment.variables = {
        NIXOS_OZONE_WL = "1";
        _JAVA_AWT_WM_NONEREPARENTING = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ANKI_WAYLAND = "1";
        # For Orca-slicer to actually show
        WEBKIT_DISABLE_COMPOSITING_MODE = "1";
        WLR_DRM_NO_ATOMIC = "1";
      };
    })

    # Session for greetd
    (mkIf (cfg.desktop == "Hyprland") {
      services.displayManager.sessionPackages = [ pkgs.hyprland ];

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        config.common = {
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
          "org.freedesktop.portal.FileChooser" = [ "xdg-desktop-portal-gtk" ];
        };
        extraPortals = [
          pkgs.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      # allow wayland lockers to unlock the screen
      security.pam.services.hyprlock.text = "auth include login";
    })
  ];
}
