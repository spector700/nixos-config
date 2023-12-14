#
# Shell
#


{ pkgs, location, ... }:

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
        rebuild_desktop = "nh os switch -H desktop";
        create = "sh ~/Projects/create/dev-assistant.sh";
        ".." = "cd ..";
        "..." = "cd ../..";
        ".3" = "cd ../../..";
        nn = "cd && cd ${location} && nvim";
        cleanup = "sudo nix-collect-garbage --delete-older-than 1d";
        listgen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
        cat = "bat";
        l = "eza -la --git --icons --color=auto --group-directories-first -s extension";

        lg = "lazygit";
      };
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
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
