{ config, ... }:
let
  variant = config.theme.name;
  colors = config.programs.matugen.theme.colors.colors.${variant};

  font_family = "Inter";
in
{
  programs.hyprlock = {
    enable = true;
    general.hide_cursor = false;
    backgrounds = [
      {
        monitor = "";
        path = "${config.home.homeDirectory}/wallpaper.png";
      }
    ];

    input-fields = [
      {
        monitor = "DP-2";

        size = {
          width = 300;
          height = 50;
        };

        outline_thickness = 2;

        outer_color = "rgb(${colors.primary})";
        inner_color = "rgb(${colors.on_primary_container})";
        font_color = "rgb(${colors.primary_container})";

        fade_on_empty = false;
        placeholder_text = ''<span font_family="${font_family}" foreground="##${colors.primary_container}">Password...</span>'';

        dots_spacing = 0.3;
        dots_center = true;
      }
    ];

    labels = [
      {
        monitor = "";
        text = "$TIME";
        inherit font_family;
        font_size = 50;
        color = "rgb(${colors.primary})";

        position = {
          x = 0;
          y = 80;
        };

        valign = "center";
        halign = "center";
      }
    ];
  };
}
