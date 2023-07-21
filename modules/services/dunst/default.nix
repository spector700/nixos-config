#
# System notifications
#

{ pkgs, ... }:

{
  
  services.dunst = {
      enable = true;
      iconTheme = {                                       # Icons
        name = "Papirus Dark";
        package = pkgs.papirus-icon-theme;
        size = "16x16";
      };
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
              #format = ''<b>%s</b>\n%b'';
              format = "󰟪 %a\n<b>󰋑 %s</b>\n%b";
              alignment = "left";
              progress_bar = true;
              vertical_alignment = "center";
              icon_position = "left";
              icon_corner_radius = 5;
              indicate_hidden = "yes";
              history_length = 20;
              always_run_script = true;
              corner_radius = 10;
              word_wrap = "yes";
              ellipsize = "middle";
              ignore_newline = "no";
              show_indicators = "yes";
              sort = true;
              scale = 0;
              stack_duplicates = true;
              hide_duplicate_count = true;
              # Mouse
              mouse_left_click = "close_current";
              mouse_middle_click = "do_action, close_current";
              mouse_right_click = "close_all";
            };
            urgency_low = {                                   # Colors
              background = "#181825";
              foreground = "#f5e0dc";
              frame_color = "#f5c2e7";
              icon = "~/.config/dunst/icons/low.svg";
              timeout = 4;
            };
            urgency_normal = {
              background = "#313244";
              foreground = "#f5e0dc";
              icon = "~/.config/dunst/icons/pokeball.svg";
              timeout = 4;
            };
            urgency_critical = {
              background = "#f5e0dc";
              foreground = "#1e1e2e";
              frame_color = "#f38ba8";
              icon = "~/.config/dunst/icons/critical.svg";
              timeout = 10;
            };
            fullscreen_show_critical = {
                msg_urgency = "critical";
                fullscreen = "show";
            };
            volume-control = {
                summary = "volctl";
                format = ''<span size="250%">%a</span>\n%b'';
            };
        };
  };
  home.file = {
      ".config/dunst/icons/".source = ./icons;
  };


}
