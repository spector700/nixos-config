{
  lib,
  pkgs,
  osConfig,
  inputs,
  config,
  ...
}:
let
  inherit (lib)
    mkForce
    mkIf
    optionals
    getExe
    ;
  cfg = osConfig.modules.display.desktop;

  brightness = "${getExe pkgs.brightnessctl}";
  media = "${getExe pkgs.playerctl}";
  volume = "${pkgs.wireplumber}/bin/wpctl";
in
{
  imports = [
    { nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ]; }
  ];

  config = mkIf cfg.niri.enable {

    home.packages = [ pkgs.nautilus ];

    # Import the animation file
    xdg.configFile."niri/animations.kdl".source = ./burn-ashes.kdl;
    xdg.configFile.niri-config.source = mkForce (
      inputs.niri-flake.lib.internal.validated-config-for pkgs config.programs.niri.package ''
        ${config.programs.niri.finalConfig}
        include optional=true "${./burn-ashes.kdl}"
      ''
    );

    programs.niri = {
      settings =

        # ==========================================
        # OUTPUT / MONITOR CONFIGURATION
        # ==========================================
        let
          monitorsList = osConfig.modules.display.monitors;

          mkOutput =
            monitor:
            let
              inherit (lib)
                elemAt
                hasPrefix
                last
                nameValuePair
                optionalAttrs
                splitString
                toInt
                ;

              resolution = splitString "x" monitor.resolution;
              position = splitString "x" monitor.position;
              rotation =
                if hasPrefix "transform" monitor.rotation then
                  (toInt (last (splitString "," monitor.rotation))) * 90
                else
                  null;
            in
            nameValuePair monitor.name (
              {
                scale = builtins.fromJSON monitor.scale;
                focus-at-startup = monitor.primary;
                variable-refresh-rate = true;
              }
              // optionalAttrs (monitor.resolution != "preferred") {
                mode = {
                  width = toInt (elemAt resolution 0);
                  height = toInt (elemAt resolution 1);
                  refresh = 1.0 * monitor.refreshRate;
                };
              }
              // optionalAttrs (!(hasPrefix "auto" monitor.position)) {
                position = {
                  x = toInt (elemAt position 0);
                  y = toInt (elemAt position 1);
                };
              }
              // optionalAttrs (rotation != null) {
                transform.rotation = rotation;
              }
            );

          outputs = builtins.listToAttrs (map mkOutput monitorsList);
        in
        {
          environment = {
            CLUTTER_BACKEND = "wayland";
            MOZ_ENABLE_WAYLAND = "1";
            SDL_VIDEODRIVER = "wayland";
            WLR_NO_HARDWARE_CURSORS = "1";
          };

          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;
          gestures.hot-corners.enable = false;

          # ==========================================
          # HARDWARE INPUT & TOUCHPAD MANAGEMENT
          # ==========================================
          input = {
            focus-follows-mouse.enable = true;
            warp-mouse-to-focus.enable = false;

            keyboard = {
              xkb = {
                layout = "us";
                options = "caps:escape";
              };
              repeat-rate = 40;
              repeat-delay = 250;
              numlock = true;
            };

            touchpad = {
              natural-scroll = true;
              tap = true;
              dwt = true; # disable-while-typing
            };

            mouse = {
              accel-profile = "flat";
            };
          };

          inherit outputs;

          # ==========================================
          # LAYOUT STYLE, WINDOW GAPS, & BLUR
          # ==========================================
          layout = {
            # default-column-width.proportion = 0.5;
            always-center-single-column = true;
            gaps = 6;
            struts.left = 4;
            struts.right = 4;
            border.width = 1;

            tab-indicator = {
              place-within-column = true;
              width = 4;
              gap = 2;
              corner-radius = 20;
              gaps-between-tabs = 6;
            };

            preset-column-widths = [
              { proportion = 1.0 / 3.0; }
              { proportion = 1.0 / 2.0; }
              { proportion = 2.0 / 3.0; }
            ];
          };

          # ==========================================
          # KEYBINDINGS & WORKFLOW CONTROLS
          # ==========================================
          binds =
            let
              actions = config.lib.niri.actions;
            in
            {
              # terminal
              "Mod+T".action.spawn = "${lib.getExe pkgs.kitty}";
              "Mod+E".action.spawn-sh = "${lib.getExe pkgs.kitty} -e yazi";
              "Ctrl+Shift+Escape".action.spawn-sh = "${lib.getExe pkgs.kitty} -e btop";

              "Mod+B".action.spawn =
                getExe
                  inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;

              "Mod+N" = {
                hotkey-overlay.title = "Focus or Launch Obsidian";
                action.spawn = "${lib.getExe pkgs.obsidian}";
              };

              # "Mod+S".action.spawn-sh =
              #   "niri msg workspaces | grep \"\\*.*special\" && niri msg action focus-workspace-previous || niri msg action focus-workspace special";
              # Stable niri-scratchpad uses a visible named stash workspace.
              "Mod+S".action.spawn = [
                "niri-scratchpad"
                "target"
                "--spawn"
                "feishin"
                "appid"
                "feishin"
              ];

              "Mod+Slash".action = actions.show-hotkey-overlay;
              "Mod+Q".action = actions.close-window;
              "Mod+F".action = actions.fullscreen-window;
              "Mod+Shift+F".action = actions.toggle-window-floating;
              "Mod+O".action = actions.toggle-overview;
              "Mod+C".action = actions.center-column;
              "Mod+M".action = actions.maximize-column;
              "Mod+W".action = actions.toggle-column-tabbed-display;

              # MOVE FOCUS

              "Mod+H".action = actions.focus-column-or-monitor-left;
              "Mod+L".action = actions.focus-column-or-monitor-right;
              "Mod+K".action = actions.focus-window-or-workspace-up;
              "Mod+J".action = actions.focus-window-or-workspace-down;

              "Mod+Left".action = actions.focus-column-or-monitor-left;
              "Mod+Right".action = actions.focus-column-or-monitor-right;
              "Mod+Up".action = actions.focus-window-up;
              "Mod+Down".action = actions.focus-window-down;

              "Mod+Ctrl+H".action = actions.consume-or-expel-window-left;
              "Mod+Ctrl+L".action = actions.consume-or-expel-window-right;
              "Mod+Ctrl+J".action = actions.focus-workspace-down;
              "Mod+Ctrl+K".action = actions.focus-workspace-up;

              "Mod+Shift+H".action = actions.move-column-to-monitor-left;
              "Mod+Shift+L".action = actions.move-column-to-monitor-right;
              "Mod+Shift+J".action = actions.move-window-to-monitor-down;
              "Mod+Shift+K".action = actions.move-window-to-monitor-up;

              "Mod+Shift+Left".action = actions.consume-or-expel-window-left;
              "Mod+Shift+Right".action = actions.consume-or-expel-window-right;
              "Mod+Shift+Down".action = actions.move-window-to-workspace-down;
              "Mod+Shift+Up".action = actions.move-window-to-workspace-up;
              # "Mod+Shift+Down".action = actions.move-window-to-monitor-down;
              # "Mod+Shift+Up".action = actions.move-window-to-monitor-up;

              "Mod+R".action = actions.switch-preset-column-width;
              # "Mod+Equal".action.set-column-width = "+10%";
              # "Mod+Minus".action.set-column-width = "-10%";
              # "Mod+Shift+Equal".action.set-window-height = "+10%";
              # "Mod+Shift+Minus".action.set-window-height = "-10%";

              "XF86AudioPlay".action.spawn-sh = "${media} play-pause";
              "XF86AudioNext".action.spawn-sh = "${media} next";
              "XF86AudioPrev".action.spawn-sh = "${media} previous";
              "XF86AudioMute".action.spawn-sh = "${volume} set-mute @DEFAULT_AUDIO_SINK@ toggle";
              "XF86AudioMicMute".action.spawn-sh = "${volume} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
              "XF86AudioRaiseVolume".action.spawn-sh = "${volume} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume".action.spawn-sh = "${volume} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-";

              "XF86MonBrightnessUp".action.spawn-sh = "${brightness} s 5%+";
              "XF86MonBrightnessDown".action.spawn-sh = "${brightness} s 5%-";

              "Print".action.spawn = [
                "sh"
                "-c"
                "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.swappy}/bin/swappy -f -"
              ];
            }
            // (lib.mergeAttrsList (
              builtins.genList (
                i:
                let
                  ws = if i == 0 then 10 else i;
                in
                {
                  "Mod+${toString i}".action.focus-workspace = ws;
                  "Shift+ALT+${toString i}".action.move-window-to-workspace = ws;
                  # "Shift+ALT+${toString i}".action.move-column-to-workspace = ws;
                }
              ) 9
            ));

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          workspaces = {
            "special" = {
              open-on-output = "DP-1";
            };
            "stash" = { };
          };

          # ==========================================
          # WINDOW RULES, TRANSPARENCY & GEOMETRY
          # ==========================================

          window-rules = [
            {
              matches = [
                {
                  is-window-cast-target = true;
                }
              ];
              focus-ring = {
                active.color = "#f38ba8";
                inactive.color = "#7d0d2d";
              };
              border.inactive.color = "#7d0d2d";
              shadow.color = "#7d0d2d70";
              tab-indicator = {
                active.color = "#f38ba8";
                inactive.color = "#7d0d2d";
              };
            }
            {
              matches = [ { app-id = "feishin"; } ];
              max-width = 1000;
              max-height = 800;
              open-on-workspace = "stash";
              open-floating = true;
              open-focused = false;
            }
            {
              geometry-corner-radius = {
                top-left = 8.0;
                top-right = 8.0;
                bottom-left = 8.0;
                bottom-right = 8.0;
              };
              opacity = 0.97;
              clip-to-geometry = true;
              draw-border-with-background = false;
            }
            {
              matches = [ { app-id = "^vesktop$"; } ];
              open-on-output = (builtins.elemAt monitorsList 1).name;
            }
            {
              matches = [
                {
                  app-id = "^(steam_app_.*|lutris_game_class|ffxiv|minigalaxy|playnite_game_class|gamescope|chiaki|.*[Ww]ine.*)$";
                }
              ];
              open-fullscreen = true;
            }
            {
              matches = [
                { app-id = "steam"; }
                { title = "^notificationtoasts_\\d+_desktop$"; }
              ];

              default-floating-position = {
                relative-to = "bottom-right";
                x = 10;
                y = 10;
              };
            }
            {
              matches = [ { app-id = "^steam.*$"; } ];
              open-on-workspace = "8";
            }
            {
              matches = [
                { app-id = "zen"; }
                { app-id = "brave"; }
                { app-id = "xdg-desktop-portal-gtk"; }
              ];
              scroll-factor = 0.9;
            }
            {
              matches = [
                { app-id = "zen"; }
                { app-id = "brave"; }
              ];
              opacity = 1.0;
            }
            {
              matches = [
                { title = "^Picture-in-Picture$"; }
              ];
              open-floating = true;
              default-floating-position = {
                x = 32;
                y = 32;
                relative-to = "bottom-right";
              };
              default-column-width.fixed = 480;
              default-window-height.fixed = 270;
            }
            {
              matches = [
                { title = "Discord Popout"; }
              ];
              open-floating = true;
              default-floating-position = {
                x = 32;
                y = 32;
                relative-to = "bottom-right";
              };
            }
            {
              matches = [
                { app-id = "dialog"; }
                { app-id = "popup"; }
                { app-id = "task_dialog"; }
                { app-id = "gcr-prompter"; }
                { app-id = "file-roller"; }
                { app-id = "xdg-desktop-portal-gtk"; }
                { app-id = "org.kde.polkit-kde-authentication-agent-1"; }
                { app-id = "^pavucontrol$"; }
                { app-id = "^blueman-manager$"; }
                { app-id = "^nm-applet$"; }
                { app-id = "^nm-connection-editor$"; }
                { app-id = "^qt5ct$"; }
                { app-id = "^qt6ct$"; }
                { app-id = "^yad$"; }
                { app-id = "^Signal$"; }
                { title = "Progress"; }
                { title = "File Operations"; }
                { title = "Confirm"; }
                { title = "Error"; }
              ];
              open-floating = true;
            }
          ];

          spawn-at-startup =
            optionals config.programs.nixcord.vesktop.enable [
              {
                command = [
                  (getExe config.programs.nixcord.vesktop.package)
                ];
              }
            ]

            ++ optionals config.modules.programs.spicetify.enable [
              {
                command = [
                  (getExe config.programs.spicetify.spicedSpotify)
                ];
              }
            ];
        };
    };
  };
}
