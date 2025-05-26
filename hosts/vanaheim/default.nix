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

  networking.hostName = "vanaheim";

  users.users.spector.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ98CT0YPE5rDHj3rMuu6+opqa3GWpj1M3kIGtFwCQgg spector@alfhiem"
  ];

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # No need for fonts on a server
  fonts.fontconfig.enable = mkDefault false;

  modules = {
    roles = {
      development.enable = false;
      server.enable = true;
      desktop.enable = false;
      gaming.enable = false;
      video.enable = false;
    };

    os = {
      mainUser = "spector";
      autoLogin = false;
    };

    hardware = {
      sound.enable = false;
      openrgb.enable = false;

      bluetooth.enable = false;
      printing.enable = false;
    };

    display = {
      gpuAcceleration.enable = false;
      # desktop.hyprland.enable = true;
    };

    networking.optomizeTcp = true;

    boot = {
      enableKernelTweaks = true;
      impermanence.enable = true;
    };
  };
}
