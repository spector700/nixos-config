# Gaming
#
# Do not forget to enable Steam play for all title in the settings menu
#
{ pkgs, lib, ... }:
let
  startScript = pkgs.writeShellScript "gamemode-start" ''
    # ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
    ${lib.getExe pkgs.libnotify} -a "Gamemode" "Optimizations activated"
  '';
  endScript = pkgs.writeShellScript "gamemode-end" ''
    # ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
    ${lib.getExe pkgs.libnotify} -a "Gamemode" "Optimizations deactivated"
  '';
in
{


  environment.systemPackages = with pkgs; [
    #config.nur.repos.c0deaddict.oversteer      # Steering Wheel Configuration
    lutris
    prismlauncher
    protontricks
    wineWowPackages.waylandFull
  ];

  programs = {
    steam = {
      enable = true;
      # package = pkgs.steam.override { extraProfile = "export GDK_SCALE=2"; };
    };
    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        custom = {
          start = startScript.outPath;
          end = endScript.outPath;
        };
      };
    };
  };
}
