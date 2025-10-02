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
  };
}
