{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    ./optomize.nix
    ./ssh.nix
  ];

  options.modules.system.networking = {
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
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
  };
}