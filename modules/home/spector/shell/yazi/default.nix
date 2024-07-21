{ config, pkgs, ... }:
let
  flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "";
    hash = "sha256-QpQnOmEeIdUd8OeY3u2BpnfJXz/7v0GbspV475p1gBE=";
  };
in
{
  home.file.".config/yazi/flavors/catppuccin-mocha.yazi" = {
    source = "${flavors}/catppuccin-mocha.yazi";
    recursive = true;
  };

  imports = [ ./plugins/starship.nix ];

  # yazi file manager
  programs.yazi = {
    enable = true;

    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;

    theme.flavor.use = "catppuccin-mocha";

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
