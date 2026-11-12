_: {
  flake.aspects.syncthing.nixos =
    { config, ... }:
    let
      username = config.modules.os.mainUser;
    in
    {
      # You can open the web interface at http://127.0.0.1:8384/ to configure and use it.
      services.syncthing = {
        enable = true;
        openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
        user = username;
        dataDir = "/home/${username}";
      };
    };
}
