{ inputs, pkgs, ... }:
let
  koshi = pkgs.callPackage ../../../../pkgs/ags { inherit inputs; };
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  home.packages = with pkgs; [
    koshi
    # inputs.matugen.packages.${pkgs.system}.default
    # dart-sass
    gtk3 # gtk-launch
    # brightnessctl
    # fd
    # swww
  ];

  programs.ags = {
    enable = true;
    configDir = koshi;
  };
}
