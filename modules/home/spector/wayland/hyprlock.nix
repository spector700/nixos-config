{
  config,
  lib,
  osConfig,
  ...
}:
let
  # variant = config.theme.name;
  variant = "dark";
  colors = config.programs.matugen.theme.colors.colors.${variant};
  inherit (lib) optionals head filter;
  inherit (osConfig.modules.display) monitors;

  font_family = "Inter";
in
{

  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = false;
      background = [
        {
          monitor = "";
          path = builtins.toString config.theme.wallpaper;
          blur_passes = 3;
          blur_size = 6;
        }
      ];

      input-fields = [
        {
          monitor = optionals (monitors != [ ]) (head (filter (x: x.primary or false) monitors)).name;

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

      label = [
        {
          monitor = "";
          text = "$TIME";
          inherit font_family;
          font_size = 50;
          color = "rgb(${colors.primary})";

          position = "0, 150";

          valign = "center";
          halign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:3600000] date +'%a %b %d'";
          inherit font_family;
          font_size = 20;
          color = "rgb(${colors.primary})";

          position = "0, 50";

          valign = "center";
          halign = "center";
        }
      ];
    };
  };
}
