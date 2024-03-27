{ config, lib, pkgs, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.meta) getExe;

  inherit (config.modules) system;
  inherit (config.modules) env;

  # make desktop session paths available to greetd
  sessionData = config.services.xserver.displayManager.sessionData.desktops;
  sessionPaths = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];


  initialSession = {
    user = "${system.mainUser}";
    command = "${env.desktop}";
  };

  defaultSession = {
    user = "greeter";
    command = concatStringsSep " " [
      (getExe pkgs.greetd.tuigreet)
      "--time"
      "--remember"
      "--remember-user-session"
      "--asterisks"
      "--sessions '${sessionPaths}'"
    ];
  };
in
{
  # greetd display manager
  services.greetd = {
    enable = true;
    vt = 2;
    restart = !system.autoLogin;

    # <https://man.sr.ht/~kennylevinsen/greetd/>
    settings = {
      # default session is what will be used if no session is selected
      # in this case it'll be a TUI greeter
      default_session = defaultSession;

      # initial session
      initial_session = mkIf system.autoLogin initialSession;
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
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
}
