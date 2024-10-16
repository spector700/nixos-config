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
    nix.settings = {
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    home.packages = with pkgs; [
      grimblast
      wl-clipboard
      wlsunset
      #TODO change when cliphist pr merge
      (cliphist.overrideAttrs (_old: {
        src = pkgs.fetchFromGitHub {
          owner = "sentriz";
          repo = "cliphist";
          rev = "c49dcd26168f704324d90d23b9381f39c30572bd";
          sha256 = "sha256-2mn55DeF8Yxq5jwQAjAcvZAwAg+pZ4BkEitP6S2N0HY=";
        };
        vendorHash = "sha256-M5n7/QWQ5POWE4hSCMa0+GOVhEDCOILYqkSYIGoy/l0=";
      }))
    ];

    # services.cliphist.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.variables = [ "--all" ];
    };

    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      NIXOS_OZONE_WL = "1";
      WEBKIT_DISABLE_COMPOSITING_MODE = "1"; # For Orca-slicer to actually show
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
