{
  lib,
  pkgs,
  osConfig,
  inputs,
  config,
  ...
}:
let
  inherit (lib) mkIf optionals getExe;
  cfg = osConfig.modules.display.desktop;

  brightness = "${getExe pkgs.brightnessctl}";
  volume = "${pkgs.wireplumber}/bin/wpctl";
in
{

  config = mkIf cfg.niri.enable {

    # programs.noctalia-shell = {
    #   enable = true;
    #   package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # };

    programs.niri = {
      settings =
        let
          monitorsList = osConfig.modules.display.monitors;

          # Derive Niri output config from the shared monitors list
          outputs = builtins.listToAttrs (
            map (
              m:
              let
                inherit (lib)
                  splitString
                  toInt
                  optionalAttrs
                  hasPrefix
                  last
                  elemAt
                  nameValuePair
                  ;

                resParts = splitString "x" m.resolution;
                posParts = splitString "x" m.position;

                rotationDeg =
                  if hasPrefix "transform" m.rotation then (toInt (last (splitString "," m.rotation))) * 90 else null;
              in
              nameValuePair m.name (
                {
                  scale = builtins.fromJSON m.scale;
                }

                # Mode — skip when resolution is "preferred" (auto-detect)
                // optionalAttrs (m.resolution != "preferred") {
                  mode = {
                    width = toInt (elemAt resParts 0);
                    height = toInt (elemAt resParts 1);
                    refresh = 1.0 * m.refreshRate;
                  };
                }

                # Position — only skip when "auto" (let niri auto-place)
                // optionalAttrs (!(hasPrefix "auto" m.position)) {
                  position = {
                    x = toInt (elemAt posParts 0);
                    y = toInt (elemAt posParts 1);
                  };
                }

                # Rotation
                // optionalAttrs (rotationDeg != null) {
                  transform.rotation = rotationDeg;
                }

                # VRR — matches Hyprland's misc.vrr = 1 (adaptive sync)
                // {
                  variable-refresh-rate = true;
                }
              )
            ) monitorsList
          );
        in
        {
          environment = {
            CLUTTER_BACKEND = "wayland";
            MOZ_ENABLE_WAYLAND = "1";
            SDL_VIDEODRIVER = "wayland";
            WLR_RENDERER = "vulkan";
            WLR_NO_HARDWARE_CURSORS = "1";
            QT_QPA_PLATFORMTHEME = "qt6ct";
            GTK_IM_MODULE = "simple";
            XDG_CURRENT_DESKTOP = "niri";
            XDG_SESSION_DESKTOP = "niri";
          };

          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;
          gestures.hot-corners.enable = false;

          # ==========================================
          # HARDWARE INPUT & TOUCHPAD MANAGEMENT
          # ==========================================
          input = {
            focus-follows-mouse.enable = true;
            warp-mouse-to-focus.enable = true;

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

          # blur = {
          #   enable = true; # set false to kill all blur globally
          #   passes = 4; # more passes = larger/smoother blur, more GPU
          #   offset = 3.0; # pixel offset multiplier per pass
          #   noise = 0.2; # reduces color banding
          #   saturation = 1.5; # > 1.0 boosts colors in blurred area
          # };

          # ==========================================
          # OUTPUT / MONITOR CONFIGURATION
          # ==========================================
          inherit outputs;

          # ==========================================
          # LAYOUT STYLE, WINDOW GAPS, & BLUR
          # ==========================================
          layout = {
            default-column-width.proportion = 0.5;
            always-center-single-column = false;
            gaps = 6;
            struts.left = 4;
            struts.right = 4;
            border.width = 1;

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
            with config.lib.niri.actions;
            {
              # terminal
              "Mod+T".action.spawn = "${lib.getExe pkgs.kitty}";
              "Mod+E".action.spawn-sh = "${lib.getExe pkgs.kitty} -e yazi";
              "Ctrl+Shift+Escape".action.spawn-sh = "${lib.getExe pkgs.kitty} -e btop";

              "Mod+B".action.spawn =
                getExe
                  inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;

              "Mod+S".action = focus-workspace "spotify";

              "Mod+Slash".action = show-hotkey-overlay;
              "Mod+Q".action = close-window;
              "Mod+F".action = fullscreen-window;
              "Mod+Shift+F".action = toggle-window-floating;
              "Mod+O".action = toggle-overview;
              "Mod+C".action = center-column;
              "Mod+M".action = maximize-column;
              "Mod+W".action = toggle-column-tabbed-display;

              "Mod+H".action = focus-column-or-monitor-left;
              "Mod+Left".action = focus-column-or-monitor-left;
              "Mod+L".action = focus-column-or-monitor-right;
              "Mod+Right".action = focus-column-or-monitor-right;
              "Mod+K".action = focus-window-or-workspace-up;
              "Mod+Up".action = focus-window-or-workspace-up;
              "Mod+J".action = focus-window-or-workspace-down;
              "Mod+Down".action = focus-window-or-workspace-down;

              "Mod+Ctrl+J".action = focus-workspace-down;
              "Mod+Ctrl+K".action = focus-workspace-up;

              "Mod+Shift+H".action = move-column-to-monitor-left;
              "Mod+Shift+Left".action = consume-or-expel-window-left;
              "Mod+Shift+L".action = move-column-to-monitor-right;
              "Mod+Shift+Right".action = consume-or-expel-window-right;
              "Mod+Shift+J".action = move-window-to-monitor-down;
              "Mod+Shift+Down".action = move-window-to-monitor-down;
              "Mod+Shift+K".action = move-window-to-monitor-up;
              "Mod+Shift+Up".action = move-window-to-monitor-up;

              "Mod+Ctrl+H".action = consume-or-expel-window-left;
              "Mod+Ctrl+L".action = consume-or-expel-window-right;

              "Mod+R".action = switch-preset-column-width;
              "Mod+Equal".action.set-column-width = "+10%";
              "Mod+Minus".action.set-column-width = "-10%";
              "Mod+Shift+Equal".action.set-window-height = "+10%";
              "Mod+Shift+Minus".action.set-window-height = "-10%";

              # "Mod+M".spawn-sh = "${config.pkgs.alsa-utils}/bin/amixer sset Capture toggle";

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
                  "Mod+Shift+${toString i}".action.move-window-to-workspace = ws;
                  "Mod+Ctrl+Shift+${toString i}".action.move-column-to-workspace = ws;
                }
              ) 9
            ));

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          workspaces = {
            "spotify" = { };
          };

          # ==========================================
          # WINDOW RULES, TRANSPARENCY & GEOMETRY
          # ==========================================
          window-rules = [
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
              # background-effect = {
              #   blur = true;
              # };
            }
            {
              matches = [ { app-id = "^discord$"; } ];
              open-on-workspace = "4";
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
              # open-maximized = true;
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
            # {
            #   matches = [{
            #     app-id = "io.github.didley.CamOverla";
            #   }];
            #   open-floating = true;
            #   open-on-output = "HDMI-A-1";
            #   default-window-height.fixed = 370;
            #   default-column-width.fixed = 280;
            #   default-floating-position = {
            #     x = 15;
            #     y = 402;
            #     relative-to = "bottom-left";
            #   };
            # }
          ];

          layer-rules = [
            {
              matches = [
                { namespace = "^noctalia-wallpaper*"; }
              ];
              place-within-backdrop = true;
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
