{
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    # ./plugins/git.nix
    ./plugins/mediainfo.nix
    ./plugins/ouch.nix
    # ./plugins/starship.nix
  ];

  # yazi file manager
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    enableZshIntegration = config.programs.zsh.enable;
    initLua = ''
      require("gvfs"):setup({})
    '';
    plugins = {
      inherit (pkgs.yaziPlugins) gvfs chmod;
    };

    keymap = {
      cmp.prepend_keymap = [
        {
          on = [ "~" ];
          run = "help";
          desc = "Open help";
        }
      ];

      mgr.prepend_keymap = [
        {
          on = [ "q" ];
          run = "close";
          desc = "Close the current tab; if it's the last tab, exit the process instead.";
        }
        {
          on = [
            "g"
            "n"
          ];
          run = "cd ~/Nextcloud";
          desc = "Go to Nextcloud";
        }
        {
          run = "plugin gvfs -- select-then-mount jump";
          on = [
            "M"
            "m"
          ];
          desc = "Mount and jump to device";
        }
        {
          run = "plugin gvfs -- select-then-unmount --eject";
          on = [
            "M"
            "u"
          ];
          desc = "Unmount and eject device";
        }
        {
          run = "plugin gvfs -- jump-to-device";
          on = [
            "g"
            "m"
          ];
          desc = "Jump to mounted device";
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
      mgr = {
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

      pick = {
        open_title = "Open with:";
        open_origin = "hovered";
        open_offset = [
          0
          1
          50
          7
        ];
      };

      preview = {
        tab_size = 2;
        max_width = 1024;
        max_height = 1920;
        cache_dir = "${config.xdg.cacheHome}";
      };

      # Prevent yazi from freezing while preloading/previewing files over slow
      # gvfs mounts (MTP, remote filesystems, etc.)
      plugin = {
        prepend_preloaders = [
          {
            url = "/run/user/1000/gvfs/**/*";
            run = "noop";
          }
        ];
        prepend_previewers = [
          {
            url = "*/";
            run = "folder";
          }
          {
            url = "/run/user/1000/gvfs/**/*";
            run = "noop";
          }
        ];
      };
    };
  };
}
