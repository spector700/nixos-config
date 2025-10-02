{ config, lib, ... }:
{
  options.modules.networking.tailscale.enable = lib.mkEnableOption "tailscale";

  config = lib.mkIf config.modules.networking.tailscale.enable {
    services.tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscale-key.path;
    };
    age.secrets.tailscale-key = {
      file = ./secrets/tailscale-key-${config.networking.hostName}.age;
      mode = "400";
    };
  };
}
