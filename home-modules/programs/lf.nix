# lf file manager
{ inputs, pkgs, ... }: {
  home.packages = [ pkgs.ctpv ];

  programs.lf = {
    enable = true;

    settings = {
      preview = true;
      hidden = true;
      drawbox = true;
      icons = true;
      ignorecase = true;
      scrolloff = 10;
      # Automatic refresh
      period = 1;
    };

    commands = {
      open = ''
        &{{
            case $(file --mime-type -Lb $f) in
                text/*) lf -remote "send $id \$$EDITOR \$fx";;
                *) for f in $fx; do $OPENER $f > /dev/null 2> /dev/null & done;;
            esac
        }}
      '';

      mkdir = ''
        ''${{
            printf "Directory Name: "
            read DIR
            mkdir $DIR
          }}
      '';

      on-select = ''
        &{{
            lf -remote "send $id set statfmt \"$(exa -ld --color=always "$f")\""
        }}
      '';

      fzf_jump = ''
          ''${{
            res="$(find . | ${pkgs.fzf}/bin/fzf --preview 'bat --color=always {}' --border --header='Jump to location')"
            if [ -n "$res" ]; then
                if [ -d "$res" ]; then
                    cmd="cd"
                else
                    cmd="select"
                fi
                res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"
                lf -remote "send $id $cmd \"$res\""
            fi
        }}
      '';

      fzf_search = ''
        ''${{
        RG_PREFIX="${pkgs.ripgrep}/bin/rg --column --line-number --no-heading --color=always --smart-case "
        res="$(
            FZF_DEFAULT_COMMAND="$RG_PREFIX ''''" \
                ${pkgs.fzf}/bin/fzf --bind "change:reload:$RG_PREFIX {q} || true" \
                --ansi --layout=reverse --header 'Search in files' \
                | cut -d':' -f1 | sed 's/\\/\\\\/g;s/"/\\"/g'
        )"
        [ -n "$res" ] && lf -remote "send $id select \"$res\""
        }}
      '';

      extract = ''
          ''${{
            set -f
            case $f in
                *.tar.bz|*.tar.bz2|*.tbz|*.tbz2) tar xjvf $f;;
                *.tar.gz|*.tgz) tar xzvf $f;;
                *.tar.xz|*.txz) tar xJvf $f;;
                *.zip) unzip $f;;
                *.rar) unrar x $f;;
                *.7z) 7z x $f;;
            esac
        }}
      '';

      zip = ''
        ''${{
                set -f
                mkdir $1
                cp -r $fx $1
                zip -r $1.zip $1
                rm -rf $1
              }}'';

      trash = "%${pkgs.trash-cli}/bin/trash-put $fx";

      trash-restore = ''
          ''${{
            ids="$(echo -ne '\n' | \
              ${pkgs.trash-cli}/bin/trash-restore | \
              awk '$1 ~ /^[0-9]+/ {print $0}' | \
              ${pkgs.fzf}/bin/fzf --multi --reverse | \
              awk '{print $1}' | \
              sed -z 's/\n/,/g;s/,$/\n/')"
            echo $ids | ${pkgs.trash-cli}/bin/trash-restore
            clear
        }}
      '';
    };

    keybindings = {
      # Disable
      d = "";

      "/" = "fzf_jump";
      a = "mkdir";
      "." = "set hidden!";
      "`" = "mark-load";
      "<enter>" = "open";
      x = "cut";
      dd = "trash";
      U = "trash-restore";

      # goto
      gs = "fzf_search";
      gh = "cd";
      gd = "cd ~/Downloads";
      gD = "cd ~/Documents";
      gc = "cd ~/.config";
    };

    extraConfig = ''
      set previewer ctpv
      set cleaner ctpvclear
      &ctpv -s $id
      &ctpvquit $id
    '';
  };

  # Icons
  xdg.configFile."lf/icons".source = "${inputs.lf-icons}/etc/icons.example";

  # Colors
  xdg.configFile."lf/colors".source = "${inputs.lf-icons}/etc/colors.example";
}
