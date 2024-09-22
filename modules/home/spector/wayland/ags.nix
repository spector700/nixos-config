{ inputs, pkgs, ... }:
let
  koshi = pkgs.callPackage ../../../../pkgs/ags { inherit inputs; };
in
{
  imports = [ inputs.ags.homeManagerModules.default ];

  home.packages = with pkgs; [
    koshi
    gtk3 # gtk-launch
  ];

  programs.ags = {
    enable = true;
    configDir = koshi;
  };
}
