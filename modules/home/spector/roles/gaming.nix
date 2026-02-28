{
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
      protonplus
      protontricks
      # sgdboop # Get game art work for steam
    ];
  };
}
