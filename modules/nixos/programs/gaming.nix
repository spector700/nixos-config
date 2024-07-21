# Gaming
#
# Do not forget to enable Steam capatability for all title in the settings menu
#
{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.programs.gaming;
in
{
  options.modules.programs.gaming = {
    enable = mkEnableOption "Enable packages required for the device to be gaming-ready";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      lutris
      prismlauncher # Minecraft
      protontricks
      adwsteamgtk # Steam theme
      bottles
    ];

    boot.kernel.sysctl = {
      # default on some gaming (SteamOS) and desktop (Fedora) distributions
      # might help with gaming performance
      "vm.max_map_count" = 2147483642;
    };

    programs = {
      steam = {
        enable = true;
        # Open ports in the firewall for Steam Remote Play
        remotePlay.openFirewall = false;
        # Compatibility tools to install
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };

      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 15;
          };
        };
      };
    };
  };
}
