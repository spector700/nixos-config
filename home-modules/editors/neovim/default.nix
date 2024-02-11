# Neovim
#
{ inputs, pkgs, ... }: {

  home.packages = with pkgs; [
    inputs.Akari.packages.${system}.default
    lazygit
    ripgrep
  ];
}
