# Gaming
# Steam + MC
#
# Do not forget to enable Steam play for all title in the settings menu
#
{ inputs, pkgs, ... }: {

  imports = [ inputs.gaming.nixosModules.pipewireLowLatency ];

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
      package = pkgs.steam.override { extraProfile = "export GDK_SCALE=2"; };
    };
    gamescope.enable = true;
    gamemode.enable = true;
  };
}
