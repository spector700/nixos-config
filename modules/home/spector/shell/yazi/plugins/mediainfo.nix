{ pkgs, ... }:
{
  home.packages = with pkgs; [ mediainfo ];
  programs.yazi = {
    plugins = with pkgs.yaziPlugins; {
      inherit mediainfo;
    };
    settings.plugin = {
      prepend_preloaders = [
        {
          mime = "{audio,video,image}/*";
          run = "mediainfo";
        }
        {
          mime = "application/subrip";
          run = "mediainfo";
        }
        {
          mime = "application/postscript";
          run = "mediainfo";
        }
      ];
      prepend_previewers = [
        {
          mime = "{audio,video,image}/*";
          run = "mediainfo";
        }
        {
          mime = "application/subrip";
          run = "mediainfo";
        }
        {
          mime = "application/postscript";
          run = "mediainfo";
        }
      ];
    };
  };
}
