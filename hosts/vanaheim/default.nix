{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkDefault;

  secretsPath = (builtins.toString inputs.nix-secrets) + "/sops";

  macAddress = "92:00:06:ed:33:ca";
  networkInterface = "enp1s0";
  ipv6Address = "2a01:4f9:c010:eb77::1";
  gateway = "fe80::1";
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/sda" ]; })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  sops.secrets.ip = {
    sopsFile = "${secretsPath}/${config.networking.hostName}.yaml";
  };

  # rename the external interface based on the MAC of the interface
  services.udev.extraRules = ''SUBSYSTEM=="net", ATTR{address}=="${macAddress}", NAME="${networkInterface}"'';

  networking = {
    hostName = "vanaheim";

    interfaces."${networkInterface}" = {
      ipv6.addresses = [
        {
          address = "${ipv6Address}";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway6 = {
      address = "${gateway}";
      interface = "${networkInterface}";
    };
  };

  homelab = {
    host = {
      hostname = config.networking.hostName;
      description = "Hetzner Vanaheim server";
      interface = "enp1s0";
      ip = ipv6Address;
    };
  };

  # No need for fonts on a server
  fonts.fontconfig.enable = mkDefault false;

  modules = {
    networking = {
      avahi.enable = true;
      optomizeTcp = true;
    };

    os = {
      mainUser = "spector";
      autoLogin = false;
    };

    boot = {
      enableKernelTweaks = true;
      impermanence.enable = true;
    };

    homelab = {
      # vector.enable = true;
      grafana.enable = true;
      loki.enable = true;
      promtail.enable = true;
    };
  };
}
