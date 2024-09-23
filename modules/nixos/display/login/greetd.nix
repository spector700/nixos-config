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

  inherit (config.modules) os;
  inherit (config.modules) display;

  # make desktop session paths available to greetd
  # sessionData = config.services.displayManager.sessionData.desktops;
  # sessionPaths = concatStringsSep ":" [
  #   "${sessionData}/share/xsessions"
  #   "${sessionData}/share/wayland-sessions"
  # ];

  initialSession = {
    user = "${os.mainUser}";
    command = "${display.desktop}";
  };

  defaultSession = {
    user = "greeter";
    command = concatStringsSep " " [
      (getExe pkgs.greetd.tuigreet)
      "--time"
      "--remember"
      "--remember-user-session"
      "--asterisks"
      "--sessions '${display.desktop}'"
    ];
  };
in
{
  # greetd display manager
  services.greetd = {
    enable = true;
    vt = 2;
    restart = !os.autoLogin;

    # <https://man.sr.ht/~kennylevinsen/greetd/>
    settings = {
      # default session is what will be used if no session is selected
      # in this case it'll be a TUI greeter
      default_session = defaultSession;

      # initial session
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
      sudo.fprintAuth = true;
      hyprlock.fprintAuth = true;

      login = {
        enableGnomeKeyring = true;
        fprintAuth = true;
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
}
