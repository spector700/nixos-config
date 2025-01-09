{ inputs, pkgs, ... }:
let
  koshi = pkgs.callPackage ../../../../pkgs/ags { inherit inputs; };
in
{
  # imports = [
  #   inputs.ags.homeManagerModules.default
  # ];

  # home.packages = with pkgs; [
  #   koshi
  # ];

  # programs.ags = {
  #   enable = true;
  #   configDir = ../../../../pkgs/ags;
  #
  #   extraPackages = [
  #     inputs.ags.packages.${pkgs.system}.astal3
  #     inputs.ags.packages.${pkgs.system}.apps
  #     inputs.ags.packages.${pkgs.system}.mpris
  #     inputs.ags.packages.${pkgs.system}.hyprland
  #     inputs.ags.packages.${pkgs.system}.tray
  #   ];
  # };
}
