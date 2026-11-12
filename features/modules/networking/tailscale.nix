_: {
  flake.aspects.tailscale.nixos =
    {
      inputs,
      config,
      lib,
      ...
    }:
    let
      secretsPath = (toString inputs.nix-secrets) + "/sops";
      inherit (lib) mkIf;
    in
    {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client";
        authKeyFile = config.sops.secrets.tailscale-key.path;
        extraDaemonFlags = [ "--no-logs-no-support" ];
      };

      sops.secrets."tailscale-key" = {
        sopsFile = "${secretsPath}/${config.networking.hostName}.yaml";
      };

      environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
        "/var/cache/tailscale"
        "/var/lib/tailscale"
      ];
    };
}
