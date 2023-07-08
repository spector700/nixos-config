#
# Gaming
# Steam + MC + Emulation
#
# Do not forget to enable Steam play for all title in the settings menu
#

{ pkgs, ... }:

{
  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  environment.systemPackages = with pkgs; [
    #config.nur.repos.c0deaddict.oversteer      # Steering Wheel Configuration
    heroic                             # Game launchers
    lutris
    prismlauncher
  ];

  programs = {                                  # Needed to succesfully start Steam
    steam = {
      enable = true;
     # gamescopeSession.enable = true;
      #remotePlay.openFirewall = true;          # Ports for Stream Remote Play
    };
    gamescope.enable = true;
    

    gamemode.enable = true;                     # Better gaming performance
                                                # Steam: Right-click game - Properties - Launch options: gamemoderun %command%
                                                # Lutris: General Preferences - Enable Feral GameMode
                                                #                             - Global options - Add Environment Variables: LD_PRELOAD=/nix/store/*-gamemode-*-lib/lib/libgamemodeauto.so
  };

 # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
   # "steam"
   # "steam-original"
   # "steam-runtime"
 # ];                                            # Use Steam for Linux libraries
}
