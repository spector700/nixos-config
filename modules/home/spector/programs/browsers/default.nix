{ inputs, pkgs, ... }:
{
  imports = [ ./firefox ];
  programs.brave.enable = true;
  home.packages = with pkgs; [
    inputs.zen-browser.packages.${system}.default
  ];
}
