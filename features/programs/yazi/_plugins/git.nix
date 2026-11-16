{ pkgs, ... }:
{
  programs.yazi = {
    plugins = {
      inherit (pkgs.yaziPlugins) git;
    };

    initLua = ''
      require("git"):setup()
    '';

    settings.plugin = {
      prepend_fetchers = [
        {
          group = "git";
          url = "*";
          run = "git";
        }
        {
          group = "git";
          url = "*/";
          run = "git";
        }
      ];
    };
  };
}
