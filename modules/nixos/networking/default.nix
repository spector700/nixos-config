{ pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    ./avahi.nix
    ./optomize.nix
    ./ssh.nix
    ./tailscale.nix
  ];

  options.modules.networking = {
    optomizeTcp = mkEnableOption "TCP Optimizations";
  };

  config = {
    networking = {
      networkmanager.enable = true;

      # dns
      nameservers = [
        # cloudflare
        "1.1.1.1"
        "1.0.0.1"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];
    };

    # Network wait fails with networkmanager
    systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
      ""
      "${pkgs.networkmanager}/bin/nm-online -q"
    ];
  };
}
