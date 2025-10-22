{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.modules.desktop.bar;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  config = mkIf (cfg == "noctalia") {

    programs.noctalia-shell = {
      enable = true;
      colors = with config.lib.stylix.colors.withHashtag; {
        mError = base08;
        mOnError = base00;
        mOnPrimary = base00;
        mOnSecondary = base00;
        mOnSurface = base04;
        mOnSurfaceVariant = base04;
        mOnTeritiary = base00;
        mOutline = base02;
        mPrimary = base0B;
        mSecondary = base0A;
        mShadow = base00;
        mSurface = base00;
        mSurfaceVariant = base01;
        mTeritiary = base0D;
      };

      settings = {
        setupCompleted = true;
        bar = {
          backgroundOpacity = 0.9;
          density = "comfortable";
          floating = false;
          showCapsule = true;
          widgets = {
            left = [
              {
                id = "Workspace";
                labelMode = "name";
                hideUnoccupied = false;
              }
              {
                id = "ActiveWindow";
                showAppIcon = true;
                colorizeIcons = true;
              }
              {
                id = "SystemMonitor";
                showCpuTemp = true;
                showCpuUsage = true;
                showDiskUsage = false;
                showMemoryAsPercent = false;
                showMemoryUsage = true;
                showNetworkoStats = false;
              }
            ];
            center = [
              {
                id = "Clock";
                # customFont = "Monofur Nerd Font Mono";
                formatHorizontal = "HH:mm ddd, MMM dd";
                formatVertical = "HH mm - dd MM";
                # useCustomFont = true;
                usePrimaryColor = true;
              }
            ];
            right = [
              {
                id = "MediaMini";
                autoHide = true;
                scrollingMode = "hover";
                showAlbumArt = false;
                showVisualizer = false;
                maximumWidth = 300;
              }
              {
                id = "Spacer";
                width = 60;
              }
              {
                id = "Tray";
                colorizeIcons = false;
                blacklist = [ ];
              }
              {
                id = "Volume";
                displayMode = "onhover";
              }
              # {
              #   id = "Battery";
              #   displayMode = "alwaysShow";
              #   warningThreshold = 30;
              # }
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
            ];
          };
        };
        general = {
          # avatarImage = "/home/${user}/.face";
          dimDesktop = false;
          showScreenCorners = true;
          forceBlackScreenCorners = false;
          animationSpeed = 1.25;
        };
        location = {
          weatherEnabled = false;
        };
        wallpaper.enabled = false;
        # controlCenter = {
        #   cards = [
        #     {
        #       id = "weather-card";
        #       enabled = false;
        #     }
        #   ];
        # };
        ui = {
          fontDefault = "JetBrainsMono NF";
          fontFixed = "Maple Mono";
          fontDefaultScale = 1.25;
          fontFixedScale = 1.25;
        };
        colorSchemes = {
          generateTemplatesForPredefined = false;
          useWallpaperColors = false;
        };
        nightLight = {
          enabled = true;
          manualSunrise = "07:00";
          manualSunset = "19:30";
        };
      };
    };

    systemd.user.services = {
      noctalia-shell =
        let
          noctaliaPackage = inputs.noctalia.packages.${pkgs.system}.default;
          # noctaliaConfig = "/home/${user}/.config/noctalia/gui-settings.json";
        in
        {
          Unit = {
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
            StartLimitIntervalSec = 60;
            StartLimitBurst = 3;
            X-Restart-Triggers = [
              noctaliaPackage
              # noctaliaConfig
            ];
          };
          Install.WantedBy = [ "graphical-session.target" ];
          Service = {
            ExecStart = "${noctaliaPackage}/bin/noctalia-shell";
            Restart = "on-failure";
            RestartSec = 3;
            TimeoutStartSec = 10;
            TimeoutStopSec = 5;
            # Environment = [
            #   "NOCTALIA_SETTINGS_FALLBACK=${noctaliaConfig}"
            # ];
          };
        };
    };
  };
}
