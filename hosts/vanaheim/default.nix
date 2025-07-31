{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    (import ../disks/lvm-btrfs.nix { disks = [ "/dev/vda" ]; })
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # virtualisation = {
  #   oci-containers.backend = "docker";
  #
  #   docker = {
  #     rootless = {
  #       enable = true;
  #       setSocketVariable = true;
  #     };
  #   };
  # };

  # users.users.${config.modules.os.mainUser}.extraGroups = [ "docker" ];

  networking.hostName = "vanaheim";

  # No need for fonts on a server
  fonts.fontconfig.enable = mkDefault false;

  modules = {
    roles = {
      server.enable = true;
    };

    os = {
      mainUser = "spector";
      autoLogin = false;
    };

    # homelab = {
    # pterodactyl.enable = true;
    #   pterodactyl = {
    #     panel = {
    #       enable = true;
    #       ssl = true;
    #       users.primary = {
    #         email = "server@senveon.com";
    #         username = "spector";
    #         firstName = "Spector";
    #         lastName = "Senveon";
    #         passwordFile = pkgs.writeText "admin-password.txt" "adminadmin";
    #         # passwordFile = config.sops.secrets."passwords/spector".path;
    #         isAdmin = true;
    #       };
    #       nodes = {
    #         daemonListen = 443;
    #       };
    #       locations = {
    #         va = {
    #           short = "va";
    #           long = "vanaheim";
    #         };
    #       };
    #
    #     };
    #     wings = {
    #       enable = true;
    #       settings = {
    #         api = {
    #           ssl.enabled = false;
    #           port = 8080;
    #         };
    #         remote = "https://panel.zepherintersect.com";
    #         fqdn = "wings.zepherintersect.com";
    #         behindProxy = true;
    #         ignore_panel_config_updates = false;
    #       };
    #     };
    #   };
    # };

    boot = {
      enableKernelTweaks = true;
      impermanence.enable = true;
    };
  };
}
