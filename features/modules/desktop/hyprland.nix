{
  flake.aspects.hyprland = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        inherit (lib) mkIf;
      in
      {
        config = mkIf config.modules.display.desktop.hyprland.enable {
          programs.hyprland = {
            enable = true;
            # needed for setting the wayland environment variables
            withUWSM = true;
          };

          xdg.portal = {
            enable = true;
            extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          };

          # allow wayland lockers to unlock the screen
          security.pam.services.hyprlock.text = "auth include login";
        };
      };

    homeManager =
      {
        pkgs,
        lib,
        osConfig,
        ...
      }:
      let
        inherit (lib) mkIf mkDefault;
      in
      {
        imports = [
          ./_hyprland/binds.nix
          ./_hyprland/config.nix
          ./_hyprland/rules.nix
          ./_hyprland/startup.nix
        ];

        config = mkIf osConfig.modules.display.desktop.hyprland.enable {
          home.packages = with pkgs; [
            grimblast
            wl-clipboard
            wlsunset
          ];

          services.cliphist.enable = true;

          wayland.windowManager.hyprland = {
            enable = true;
            configType = "lua";
            # conflicts with programs.hyprland.withUWSM in nixos
            systemd.enable = false;
            package = null;
            portalPackage = null;
          };

          modules = {
            desktop = {
              hyprpaper.enable = mkDefault false;
              hypridle.enable = mkDefault false;
              hyprlock.enable = mkDefault false;
            };
          };
        };
      };
  };
}
