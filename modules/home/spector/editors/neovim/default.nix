# Neovim
#
{ inputs, pkgs, ... }:
{

  home.packages = [ inputs.Akari.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
