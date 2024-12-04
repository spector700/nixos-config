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
    mkDefault
    ;

  inherit (osConfig.modules.display) monitors;
in
{
  options.modules.desktop.hyprlock = {
    enable = mkEnableOption "Enable the hyprlock service";
  };

  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;
      settings = {
        background = mkDefault [
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
              width = 200;
              height = 25;
            };

            position = "0, 300";

            outline_thickness = 1;

            fade_on_empty = false;
            # placeholder_text = ''<span foreground="##cdd6f4"><i>󰌾 Logged in as </i><span foreground="##cba6f7">$USER</span></span>'';
            placeholder_text = "Enter Password";

            dots_spacing = 0.2;
            dots_center = true;

            shadow_color = "rgba(0, 0, 0, 0.1)";
            shadow_size = 7;
            shadow_passes = 1;
          }
        ];

        label = [
          {
            monitor = "";
            text = "$TIME";
            font_size = 60;

            position = "0, 150";

            valign = "center";
            halign = "center";
          }
          {
            monitor = "";
            text = "cmd[update:3600000] date +'%a %b %d'";
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
