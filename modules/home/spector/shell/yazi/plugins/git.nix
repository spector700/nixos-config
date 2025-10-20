{ pkgs, ... }:
{
  programs.yazi = {
    plugins = with pkgs.yaziPlugins; {
      inherit git;
    };

    initLua = ''
      require("git"):setup()
    '';

    settings.plugin = {
      prepend_fetchers = [
        {
          id = "git";
          name = "*";
          run = "git";
        }
        {
          id = "git";
          name = "*/";
          run = "git";
        }
      ];
    };
  };
}
