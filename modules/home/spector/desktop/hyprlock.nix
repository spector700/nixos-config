{
  config,
  lib,
  osConfig,
  ...
}:
let
  cfg = config.modules.desktop.hyprlock;

  inherit (lib)
    optionals
    mkIf
    mkEnableOption
    head
    filter
    ;
  inherit (osConfig.modules.display) monitors;

  font_family = "JetBrainsMono";
in
{
  options.modules.desktop.hyprlock = {
    enable = mkEnableOption "Enable the hyprlock service";
  };

  config = mkIf cfg.enable {

    programs.hyprlock = {
      enable = true;
      settings = {
        general.hide_cursor = false;
        background = [
          {
            monitor = "";
            path = builtins.toString config.modules.theme.wallpaper;
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

            fade_on_empty = false;
            placeholder_text = ''<span foreground="##cdd6f4"><i>󰌾 Logged in as </i><span foreground="##cba6f7">$USER</span></span>'';

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

            position = "0, 150";

            valign = "center";
            halign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:3600000] date +'%a %b %d'";
            inherit font_family;
            font_size = 20;

            position = "0, 50";

            valign = "center";
            halign = "center";
          }
        ];
      };
    };
  };
}
