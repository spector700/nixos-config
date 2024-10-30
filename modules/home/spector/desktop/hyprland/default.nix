{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  cfg = osConfig.modules.display.desktop;

in
{
  imports = [
    ./binds.nix
    ./config.nix
  ];

  config = mkIf cfg.hyprland.enable {
    home.packages = with pkgs; [
      grimblast
      wl-clipboard
      wlsunset
    ];

    services.cliphist.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.variables = [ "--all" ];
    };

    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      NIXOS_OZONE_WL = "1";
      WEBKIT_DISABLE_COMPOSITING_MODE = "1"; # For Orca-slicer to actually show
      __EGL_VENDOR_LIBRARY_FILENAMES = "${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json";
      __GLX_VENDOR_LIBRARY_NAME = "mesa";
    };

    modules = {
      desktop = {
        hyprpaper.enable = mkDefault true;
        hypridle.enable = mkDefault true;
        hyprlock.enable = mkDefault true;
      };
    };
  };
}
