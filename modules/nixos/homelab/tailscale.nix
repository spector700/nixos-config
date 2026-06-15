{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.homelab.tailscale;
in
{
  options.modules.homelab.tailscale = {
    enable = mkEnableOption "Enable Tailscale VPN";
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      # Allow kernel-level routing
      useRoutingFeatures = "server";
    };

    # Trust Tailscale interface -- remote Alloy agents and Prometheus scrapes come through here
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    # Persist Tailscale state so the node stays authenticated across impermanence reboots
    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      {
        directory = "/var/lib/tailscale";
        mode = "0700";
      }
    ];
  };
}
