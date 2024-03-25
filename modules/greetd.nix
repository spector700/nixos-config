{ config, lib, ... }:
let
  sys = config.modules.system;
in
{
  # greetd display manager
  services.greetd =
    let
      session = {
        command = "${lib.getExe config.programs.hyprland.package}";
        user = "${sys.mainUser}";
      };
    in
    {
      enable = true;
      settings = {
        terminal.vt = 1;
        default_session = session;
        initial_session = session;
      };
    };

  # unlock GPG keyring on login
  security.pam.services.greetd.enableGnomeKeyring = true;
}
