#
# Gaming
# Steam + MC + Emulation
#
# Do not forget to enable Steam play for all title in the settings menu
#

{ pkgs, unstable, ... }:

{
  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  environment.systemPackages = [
    #config.nur.repos.c0deaddict.oversteer      # Steering Wheel Configuration
    unstable.heroic                             # Game launchers
    unstable.lutris
    unstable.prismlauncher
    #unstable.steam
  ];

  programs = {                                  # Needed to succesfully start Steam
    steam = {
      enable = true;
      #remotePlay.openFirewall = true;          # Ports for Stream Remote Play
    };
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
