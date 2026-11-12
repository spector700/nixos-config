{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkForce;
  cfg = config.modules.display.desktop.niri;
in
{
  imports = [
    inputs.niri-flake.nixosModules.niri
    { nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ]; }
  ];

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    modules.desktop.startCommand = "${config.programs.niri.package}/bin/niri-session";

    environment.variables = {
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "niri";
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      ANKI_WAYLAND = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_QPA_PLATFORM = "wayland";
    };

    systemd.user.services.niri-flake-polkit.enable = mkForce false;
  };
}
