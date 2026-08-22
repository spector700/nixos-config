{
  inputs,
  lib,
  config,
  pkgs,
  location,
  ...
}:
let
  inherit (lib) getExe mkIf;
  cfg = config.modules.desktop.bar;
  noctalia = getExe config.programs.noctalia.package;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  config = mkIf (cfg == "noctalia") {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      #   settings = {
      #     setupCompleted = true;
      #     bar = {
      #       backgroundOpacity = 0.9;
      #       density = "comfortable";
      #       floating = false;
      #       showCapsule = true;
      #       widgets = {
      #         left = [
      #           {
      #             id = "Workspace";
      #             labelMode = "name";
      #             hideUnoccupied = false;
      #           }
      #           {
      #             id = "ActiveWindow";
      #             showAppIcon = true;
      #             colorizeIcons = true;
      #           }
      #           {
      #             id = "SystemMonitor";
      #             showCpuTemp = true;
      #             showCpuUsage = true;
      #             showDiskUsage = false;
      #             showMemoryAsPercent = false;
      #             showMemoryUsage = true;
      #             showNetworkoStats = false;
      #           }
      #         ];
      #         center = [
      #           {
      #             id = "Clock";
      #             # customFont = "Monofur Nerd Font Mono";
      #             formatHorizontal = "HH:mm ddd, MMM dd";
      #             formatVertical = "HH mm - dd MM";
      #             # useCustomFont = true;
      #             usePrimaryColor = true;
      #           }
      #         ];
      #         right = [
      #           {
      #             id = "MediaMini";
      #             autoHide = true;
      #             scrollingMode = "hover";
      #             showAlbumArt = false;
      #             showVisualizer = false;
      #             maximumWidth = 300;
      #           }
      #           {
      #             id = "Spacer";
      #             width = 60;
      #           }
      #           {
      #             id = "Tray";
      #             colorizeIcons = false;
      #             blacklist = [ ];
      #           }
      #           {
      #             id = "Volume";
      #             displayMode = "onhover";
      #           }
      #           # {
      #           #   id = "Battery";
      #           #   displayMode = "alwaysShow";
      #           #   warningThreshold = 30;
      #           # }
      #           {
      #             id = "ControlCenter";
      #             useDistroLogo = true;
      #           }
      #         ];
      #       };
      #     };
      #     general = {
      #       # avatarImage = "/home/${user}/.face";
      #       dimDesktop = false;
      #       showScreenCorners = true;
      #       forceBlackScreenCorners = false;
      #       animationSpeed = 1.25;
      #     };
      #     location = {
      #       weatherEnabled = false;
      #     };
      #     wallpaper.enabled = false;
      #     # controlCenter = {
      #     #   cards = [
      #     #     {
      #     #       id = "weather-card";
      #     #       enabled = false;
      #     #     }
      #     #   ];
      #     # };
      #     ui = {
      #       fontDefault = "JetBrainsMono NF";
      #       fontFixed = "Maple Mono";
      #       fontDefaultScale = 1.25;
      #       fontFixedScale = 1.25;
      #     };
      #     colorSchemes = {
      #       generateTemplatesForPredefined = false;
      #       useWallpaperColors = false;
      #     };
      #     nightLight = {
      #       enabled = true;
      #       manualSunrise = "07:00";
      #       manualSunset = "19:30";
      #     };
      #   };
    };

    home.packages = [ pkgs.python3 ];

    programs.niri.settings.binds = {
      "Mod+Space".action.spawn = [
        noctalia
        "msg"
        "panel-toggle"
        "launcher"
      ];
      "Mod+Shift+S".action.spawn = [
        noctalia
        "msg"
        "panel-toggle"
        "control-center"
      ];
      "Mod+Comma".action.spawn = [
        noctalia
        "msg"
        "settings-toggle"
      ];
      "Alt+Tab".action.spawn = [
        noctalia
        "msg"
        "window-switcher"
      ];
      "Mod+Alt+L".action.spawn = [
        noctalia
        "msg"
        "session"
        "lock"
      ];
    };

    home.file.".local/state/noctalia/settings.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${location}/modules/home/spector/desktop/bar/noctalia/config/settings.toml";
  };
}
