{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.modules.display.desktop.niri;
  user = config.modules.os.mainUser;
in
{
  imports = [
    inputs.niri-flake.nixosModules.niri
    { nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ]; }
  ];

  config = mkIf cfg.enable {
    home-manager.users.${user} = {
      imports = [ ./settings.nix ];
      home.packages = with pkgs; [
        nautilus
      ];
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    environment.variables = {
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";

      # XDG
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "niri";

      # Qt theming
      QT_QPA_PLATFORMTHEME = "qt5ct";

      # Disable IBus (not needed for niri)
      # This prevents the "IBus should be called from desktop session" notification
      GTK_IM_MODULE = "xim";
      QT_IM_MODULE = "xim";
      XMODIFIERS = "@im=none";
    };

    systemd.user.services.niri-flake-polkit.enable = false;
  };
}
