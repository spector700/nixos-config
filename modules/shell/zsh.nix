#
# Shell
#


{ pkgs, lib, ... }:

{

  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true; # Auto suggest options and highlights syntax, searches in history for options
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      history.size = 100000;

      oh-my-zsh = {
        # Extra plugins for zsh
        enable = true;
        plugins = [ "git" ];
      };

      initExtra = ''
        # run programs that are not in PATH with comma
        command_not_found_handler() {
        ${pkgs.comma}/bin/comma "$@"
        }
      '';

      shellAliases = {
        rebuild_desktop = "sudo nixos-rebuild switch --flake ~/.config/nixos-config#desktop";
        ".." = "cd ..";
        "..." = "cd ../..";
        ".3" = "cd ../../..";
        nn = "cd && cd .config/nixos-config && nvim";
        cleanup = "sudo nix-collect-garbage --delete-older-than 1d";
        listgen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
        cat = "bat";
        l = "exa -la --git --icons --color=auto --group-directories-first -s extension";

        lg = "lazygit";
      };
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };

    exa.enable = true;
    btop.enable = true;

  };
}
