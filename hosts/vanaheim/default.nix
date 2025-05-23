{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "vanaheim";
  };
}
