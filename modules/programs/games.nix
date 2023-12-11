#
# Gaming
# Steam + MC
#
# Do not forget to enable Steam play for all title in the settings menu
#

{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    #config.nur.repos.c0deaddict.oversteer      # Steering Wheel Configuration
    lutris
    prismlauncher
    protontricks
    protonup-qt
    wineWowPackages.waylandFull
  ];

  programs = {
    steam = {
      enable = true;
      # gamescopeSession.enable = true;
      #remotePlay.openFirewall = true;          # Ports for Stream Remote Play
    };
    gamescope.enable = true;


    gamemode.enable = true; # Better gaming performance
    # Steam: Right-click game - Properties - Launch options: gamemoderun %command%
    # Lutris: General Preferences - Enable Feral GameMode
    #                             - Global options - Add Environment Variables: LD_PRELOAD=/nix/store/*-gamemode-*-lib/lib/libgamemodeauto.so
  };
}
