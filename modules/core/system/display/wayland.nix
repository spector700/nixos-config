{ config, lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf optionalString;

  inherit (config.modules) env;
in
{
  config = mkMerge [
    (mkIf env.isWayland {
      environment.etc."greetd/environments".text = ''
        ${optionalString (env.desktop == "Hyprland") "Hyprland"}
        zsh
      '';

      environment.variables = {
        NIXOS_OZONE_WL = "1";
        _JAVA_AWT_WM_NONEREPARENTING = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ANKI_WAYLAND = "1";
        WLR_DRM_NO_ATOMIC = "1";
      };
    })

    # Session for greetd
    (mkIf (env.desktop == "Hyprland") {
      services.xserver.displayManager.sessionPackages = [ pkgs.hyprland ];
    })
  ];
}
