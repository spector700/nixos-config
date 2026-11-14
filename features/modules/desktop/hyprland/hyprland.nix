_: {
  flake.aspects = { aspects, ... }: {
    hyprland = {
      includes = with aspects; [
        graphical
        monitors
        greetd
        sound
        fonts
        kitty
        starship
        yazi
        zathura
        nixcord
        zen
        xdg
      ];

      nixos =
        {
          pkgs,
          ...
        }:
        {
          programs.hyprland = {
            enable = true;
            # needed for setting the wayland environment variables
            withUWSM = true;
          };

          modules.desktop.startCommand = "uwsm start hyprland-uwsm.desktop";

          environment.variables = {
            NIXOS_OZONE_WL = "1";
            _JAVA_AWT_WM_NONEREPARENTING = "1";
            ANKI_WAYLAND = "1";
            QT_QPA_PLATFORM = "wayland";
            QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
          };

          xdg.portal = {
            enable = true;
            extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
          };

          # allow wayland lockers to unlock the screen
          security.pam.services.hyprlock.text = "auth include login";
        };

      homeManager =
        {
          pkgs,
          ...
        }:
        {
          imports = [
            ./_binds.nix
            ./_config.nix
            ./_rules.nix
            ./_startup.nix
          ];

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
        };
    };
  };
}
