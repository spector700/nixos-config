{
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ./plugins/git.nix
    ./plugins/mediainfo.nix
    ./plugins/ouch.nix
    ./plugins/starship.nix
  ];

  # yazi file manager
  programs.yazi = {
    enable = true;

    enableZshIntegration = config.programs.zsh.enable;
    plugins = {
      inherit (pkgs.yaziPlugins)
        mount
        ;

    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = [
            "g"
            "n"
          ];
          run = "cd ~/Nextcloud";
          desc = "Go to Nextcloud";
        }
        {
          run = "plugin mount";
          on = [ "M" ];
          desc = "Disk Mounting";
        }
        {
          run = "plugin chmod";
          on = [
            "c"
            "m"
          ];
          desc = "Chmod on selected files";
        }
        {
          run = "tab_switch 1 --relative";
          on = [ "<C-Tab>" ];
        }
        {
          run = "tab_switch -1 --relative";
          on = [ "<C-BackTab>" ];
        }
        # drop to shell
        {
          on = "!";
          run = ''shell "$SHELL" --block'';
          desc = "Open shell here";
        }
        # Run ripdrag when pressing C-n
        {
          run = ''shell '${lib.getExe pkgs.ripdrag} "$@" -x 2>/dev/null &' --confirm'';
          on = [ "<C-n>" ];
        }
      ];
    };

    settings = {
      manager = {
        layout = [
          1
          4
          3
        ];
        sort_by = "natural";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
      };

      preview = {
        tab_size = 2;
        max_width = 1024;
        max_height = 1920;
        cache_dir = "${config.xdg.cacheHome}";
      };
    };
  };
}
