{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.services.syncthing;
  username = config.modules.os.mainUser;
in
{
  options.modules.services.syncthing = {
    enable = mkEnableOption "Enable Syncthing service";
  };

  config = mkIf cfg.enable {
    # You can open the web interface at http://127.0.0.1:8384/ to configure and use it.
    services.syncthing = {
      enable = true;
      openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
      user = username;
      dataDir = "/home/${username}";
    };
  };

}
