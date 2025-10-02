{
  inputs,
  config,
  lib,
  ...
}:
let
  secretsPath = (builtins.toString inputs.nix-secrets) + "/sops";
in
{
  options.modules.networking.tailscale.enable = lib.mkEnableOption "tailscale";

  config = lib.mkIf config.modules.networking.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      authKeyFile = config.sops.secrets.tailscale-key.path;
    };

    sops.secrets."tailscale-key" = {
      sopsFile = "${secretsPath}/${config.networking.hostName}.yaml";
      mode = "400";
    };
  };
}
