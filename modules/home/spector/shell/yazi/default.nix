{ inputs, config, ... }:
{

  imports = [ ./plugins/starship.nix ];

  # yazi file manager
  programs.yazi = {
    enable = true;

    enableZshIntegration = config.programs.zsh.enable;
    plugins = {
      starship = "${inputs.starship-yazi}";
    };

    keymap = {
      manager.prepend_keymap = [
        {
          on = [
            "g"
            "n"
          ];
          run = "cd ~/Nextcloud/Nextual";
          desc = "Go to Nextcloud";
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
