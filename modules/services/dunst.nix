#
# System notifications
#

{ pkgs, ... }:

{
  
  services.dusnt = {
      enable = true;
      settings = {
          global = {
              monitor = 0;
              width = 300;
              height = 200;
              origin = "top-right";
              offset = "50x50";
              shrink = "yes";
              transparency = 10;
              padding = 16;
              horizontal_padding = 16;
              frame_width = 3;       
              line_height = 4;
              idle_threshold = 120;
              markup = "full";
              format = ''<b>%s</b>\n%b'';
              alignment = "left";
              vertical_alignment = "center";
              icon_position = "left";
              word_wrap = "yes";
              ignore_newline = "no";
              show_indicators = "yes";
              sort = true;
              stack_duplicates = true;
              hide_duplicate_count = true;
            };
            urgency_low = {                                   # Colors
              background = "#181825";
              foreground = "#f5e0dc";
              frame_color = "#f5c2e7";
              timeout = 4;
            };
            urgency_normal = {
              background = "#313244";
              foreground = "#f5e0dc";
              timeout = 4;
            };
            urgency_critical = {
              background = "#f5e0dc";
              foreground = "#1e1e2e";
              frame_color = "#f38ba8";
              timeout = 10;
            };
            volume-control = {
                summary = "volctl";
                format = ''<span size="250%">%a</span>\n%b'';
              };
        };
    };


}
