{
  inputs,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = osConfig.modules.roles.gaming;
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # inputs.nix-citizen.packages.${system}.star-citizen
      lutris
      prismlauncher # Minecraft
      bottles
      rpcs3
      rusty-psn-gui
      winetricks
      wineWowPackages.waylandFull
      protonplus
      sgdboop # Get game art work for steam
    ];
  };
}
