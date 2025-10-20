{ pkgs, ... }:
{
  home.packages = with pkgs; [ ouch ];
  programs.yazi = {
    plugins = with pkgs.yaziPlugins; {
      inherit ouch;
    };
    settings = {
      opener.extract = [
        {
          run = "ouch d -y %*";
          desc = "Extract here with ouch";
          for = "windows";
        }
        {
          run = "ouch d -y \"$@\"";
          desc = "Extract here with ouch";
          for = "unix";
        }
      ];
      plugin = {
        prepend_previewers = [
          {
            mime = "application/*zip";
            run = "ouch";
          }
          {
            mime = "application/x-tar";
            run = "ouch";
          }
          {
            mime = "application/x-bzip2";
            run = "ouch";
          }
          {
            mime = "application/x-7z-compressed";
            run = "ouch";
          }
          {
            mime = "application/x-rar";
            run = "ouch";
          }
          {
            mime = "application/vnd.rar";
            run = "ouch";
          }
          {
            mime = "application/x-xz";
            run = "ouch";
          }
          {
            mime = "application/xz";
            run = "ouch";
          }
          {
            mime = "application/x-zstd";
            run = "ouch";
          }
          {
            mime = "application/zstd";
            run = "ouch";
          }
          {
            mime = "application/java-archive";
            run = "ouch";
          }
        ];
      };
    };
    keymap.mgr.prepend_keymap = [
      {
        run = "plugin ouch";
        on = [
          "c"
          "c"
        ];
        desc = "Compress with ouch";
      }
    ];
  };
}
