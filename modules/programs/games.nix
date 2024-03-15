# Gaming
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
    # wineWowPackages.waylandFull
    adwsteamgtk
  ];

  programs = {
    steam.enable = true;

    gamemode = {
      enable = true;
      enableRenice = true;
    };
  };
}
