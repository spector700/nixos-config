{ pkgs, location, inputs, ... }: {

  imports = [ inputs.dev-assistant.homeManagerModules.default ];

  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      autocd = true;
      # enableCompletion = true;
      history = { expireDuplicatesFirst = true; };

      initExtra = ''
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

        # C-Backspace / C-Delete for word deletions
        bindkey "^H" backward-kill-word

        # case insensitive tab completion
        zstyle ':completion:*' completer _complete _ignored _approximate
        zstyle ':completion:*' list-colors '\'
        zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu select
        zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
        zstyle ':completion:*' verbose true
        _comp_options+=(globdots)
      '';

      shellAliases = {
        rebuild = "nh os switch";
        create = "DevAssistant";
        ".." = "cd ..";
        "..." = "cd ../..";
        nn = "cd && cd ${location} && nvim";
        cleanup = "sudo nix-collect-garbage --delete-older-than 1d";
        listgen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
        cat = "bat";
        l = "eza -la --git --icons --color=auto --group-directories-first -s extension";
        lg = "lazygit";
      };
    };

    dev-assistant.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    bat = {
      enable = true;
      config = { pager = "less -FR"; };
    };

    eza.enable = true;
    btop.enable = true;
  };
}
