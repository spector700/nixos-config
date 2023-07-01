#
# Shell
#


{ pkgs, ... }:

{
  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;            # Auto suggest options and highlights syntax, searches in history for options
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      histSize = 100000;

      ohMyZsh = {                               # Extra plugins for zsh
        enable = true;
        plugins = [ "git" ];
      };


      shellInit = ''                            # Zsh theme
        # Spaceship
        source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
        autoload -U promptinit; promptinit
      '';     

    shellAliases = {
      rebuild_desktop= "sudo nixos-rebuild switch --flake ~/.config/nixos-config#desktop";
      ".."= "cd ..";
      "..."= "cd ../..";
      ".3"= "cd ../../..";

      lg= "lazygit";
      nv= "nvim";
    };
  };
 };
}
