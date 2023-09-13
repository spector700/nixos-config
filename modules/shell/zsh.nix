#
# Shell
#


{ pkgs, ... }:

{

  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      history.size = 100000;

      initExtra = ''
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
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
        l = "eza -la --git --icons --color=auto --group-directories-first -s extension";

        lg = "lazygit";
      };
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
    };

    eza.enable = true;
    btop.enable = true;

  };
}
