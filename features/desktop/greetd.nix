_: {
  flake.aspects.greetd.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.modules) mkIf;
      inherit (lib.strings) concatStringsSep;
      inherit (lib.meta) getExe;

      inherit (config.modules) os desktop;

      sessionData = config.services.displayManager.sessionData.desktops;
      sessionPath = "${sessionData}/share/wayland-sessions";

      initialSession = {
        user = "${os.mainUser}";
        command = desktop.startCommand;
      };

      defaultSession = {
        user = "greeter";
        command = concatStringsSep " " [
          (getExe pkgs.tuigreet)
          "--time"
          "--remember"
          "--remember-user-session"
          "--asterisks"
          "--sessions ${sessionPath}"
        ];
      };

    in
    {
      # greetd display manager
      services.greetd = {
        enable = true;
        restart = !os.autoLogin;

        # <https://man.sr.ht/~kennylevinsen/greetd/>
        settings = {
          # default session is what will be used if no session is selected
          # in this case it'll be a TUI greeter
          default_session = defaultSession;

          initial_session = mkIf os.autoLogin initialSession;
        };
      };

      # unlock GPG keyring on login
      security.pam.services =
        let
          gnupg = {
            enable = true;
            noAutostart = true;
            storeOnly = true;
          };
        in
        {
          login = {
            enableGnomeKeyring = true;
            inherit gnupg;
          };

          greetd = {
            enableGnomeKeyring = true;
            inherit gnupg;
          };

          tuigreet = {
            enableGnomeKeyring = true;
            inherit gnupg;
          };
        };
    };
}
