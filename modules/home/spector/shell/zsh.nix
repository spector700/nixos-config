{
  pkgs,
  location,
  inputs,
  ...
}:
{
  imports = [ inputs.dev-assistant.homeManagerModules.default ];

  home.packages = with pkgs; [
    # get ssh information with fzf
    dig
  ];

  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
        patterns = {
          "rm -rf *" = "fg=black,bg=red";
        };
        styles = {
          "alias" = "fg=blue";
        };
        highlighters = [
          "main"
          "brackets"
          "pattern"
        ];
      };
      history.expireDuplicatesFirst = true;

      # search sub commands
      historySubstringSearch.enable = true;

      initContent = ''
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

        show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

        # - The first argument to the function is the name of the command.
        # - You should make sure to pass the rest of the arguments to fzf.
        _fzf_comprun() {
          local command=$1
          shift

          case "$command" in
            cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
            export|unset) fzf --preview "eval 'echo ''${}'"         "$@" ;;
            ssh)          fzf --preview 'dig {}'                   "$@" ;;
            *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
          esac
        }

        # C-Backspace / C-Delete for word deletions
        bindkey "^[[127;5u" backward-kill-word

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

    zoxide = {
      enable = true;
      # alias cd to z
      options = [ "--cmd cd" ];
    };

    lazygit.enable = true;

    command-not-found.enable = false;

    tealdeer = {
      enable = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
        };
        updates.auto_update = true;
      };
    };

    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };

    dev-assistant.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
      # Ctrl - T | find file
      fileWidgetOptions = [ "--preview '$show_file_or_dir_preview'" ];
      # Alt - C | chang directory
      changeDirWidgetOptions = [ "--preview 'eza --tree --color=always {} | head -200'" ];
      # Ctrl - R
      historyWidgetOptions = [
        "--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
      ];
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
