{ config, ... }:
{
  imports = [
    ./theme/icons.nix
    ./theme/manager.nix
    ./theme/misc.nix
    ./theme/status.nix
  ];

  # yazi file manager
  programs.yazi = {
    enable = true;

    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;

    settings = {
      manager = {
        layout = [ 1 4 3 ];
        sort_by = "alphabetical";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
      };

      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        cache_dir = "${config.xdg.cacheHome}";
      };
    };
  };
}