{
  inputs,
  config,
  lib,
  ...
}:
let
  secretsPath = (builtins.toString inputs.nix-secrets) + "/sops";
  inherit (lib) mkIf;
in
{
  options.modules.networking.tailscale.enable = lib.mkEnableOption "tailscale";

  config = mkIf config.modules.networking.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      authKeyFile = config.sops.secrets.tailscale-key.path;
    };

    sops.secrets."tailscale-key" = {
      sopsFile = "${secretsPath}/${config.networking.hostName}.yaml";
      mode = "400";
    };

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      "/var/cache/tailscale"
      "/var/lib/tailscale"
    ];
  };
}
