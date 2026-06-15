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

  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (lib.splitString " " cmd);

in
{
  imports = [
    inputs.niri-flake.homeModules.niri

    # { nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ]; }
  ];

  config = mkIf cfg.niri.enable {

    # programs.noctalia-shell = {
    #   enable = true;
    #   package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # };

    programs.niri = {
      enable = true;
      # package = pkgs.niri-unstable;

      settings =
        let
          noctaliaExe = lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
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

          input = {
            focus-follows-mouse.enable = true;

            keyboard = {
              xkb = {
                layout = "us";
                options = "grp:alt_shift_toggle,caps:escape";
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

          layout = {
            default-column-width.proportion = 0.5;
            always-center-single-column = true;
            gaps = 6;
            struts.left = 4;
            struts.right = 4;
            border.width = 1;
          };

          # switch-events.lid-close.action.spawn = noctalia "lockscreen lock";

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

              # "Mod+Space".action.spawn = noctalia "launcher toggle";
              # "Mod+V".action.spawn = noctalia "launcher clipboard";
              # "Ctrl+Alt+Delete".action.spawn = noctalia "sessionMenu toggle";
              # "Mod+Escape".action.spawn = noctalia "lockScreen lock";
              # "Mod+S".action.spawn = noctalia "controlCenter";
              # "Mod+Comma".action.spawn = noctalia "settingd toggle";

              "Mod+/".action = show-hotkey-overlay;
              "Mod+Q".action = close-window;
              "Mod+F".action = fullscreen-window;
              "Mod+Shift+F".action = toggle-window-floating;
              "Mod+O".action = toggle-overview;
              "Mod+C".action = center-column;
              "Mod+M".action = maximize-column;
              "Mod+W".action = toggle-column-tabbed-display;

              "Mod+H".action = focus-column-or-monitor-left;
              "Mod+L".action = focus-column-or-monitor-right;
              "Mod+J".action = focus-window-or-workspace-down;
              "Mod+K".action = focus-window-or-workspace-up;

              "Mod+Ctrl+J".action = focus-workspace-down;
              "Mod+Ctrl+K".action = focus-workspace-up;

              "Mod+Shift+H".action = move-column-to-monitor-left;
              "Mod+Shift+L".action = move-column-to-monitor-right;
              "Mod+Shift+J".action = move-window-to-monitor-down;
              "Mod+Shift+K".action = move-window-to-monitor-up;

              "Mod+Ctrl+H".action = consume-or-expel-window-left;
              "Mod+Ctrl+L".action = consume-or-expel-window-right;

              "Mod+R".action = switch-preset-column-width;
              "Mod+Equal".action.set-column-width = "+10%";
              "Mod+Minus".action.set-column-width = "-10%";
              "Mod+Shift+Equal".action.set-window-height = "+10%";
              "Mod+Shift+Minus".action.set-window-height = "-10%";

              # "Mod+M".spawn-sh = "${config.pkgs.alsa-utils}/bin/amixer sset Capture toggle";

              "XF86AudioRaiseVolume".action.spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+";
              "XF86AudioLowerVolume".action.spawn-sh = "wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-";

              "Print".action.spawn-sh = "${lib.getExe pkgs.grimblast} --notify copysave area";

              #   "Mod+d".spawn-sh = self.mkWhichKeyExe config.pkgs [
              #     {
              #       key = "b";
              #       desc = "Bluetooth";
              #       cmd = "${noctaliaExe} ipc call bluetooth togglePanel";
              #     }
              #     {
              #       key = "w";
              #       desc = "Wifi";
              #       cmd = "${noctaliaExe} ipc call wifi togglePanel";
              #     }
              #     {
              #       key = "f";
              #       desc = "Firefox";
              #       cmd = "firefox";
              #     }
              #     {
              #       key = "t";
              #       desc = "Telegram";
              #       cmd = "Telegram";
              #     }
              #     {
              #       key = "d";
              #       desc = "Discord";
              #       cmd = "vesktop";
              #     }
              #     {
              #       key = "m";
              #       desc = "Youtube Music";
              #       cmd = "pear-desktop";
              #     }
              #     {
              #       key = "s";
              #       desc = "Pavucontrol";
              #       cmd = "${lib.getExe pkgs.pavucontrol}";
              #     }
              #   ];
            }
            // (lib.mergeAttrsList (
              builtins.genList (
                i:
                let
                  ws = if i == 0 then 10 else i;
                in
                {
                  "Mod+${toString i}".action.focus-workspace = ws;
                  "Mod+shift+${toString i}".action.move-window-to-workspace = ws;
                  "Mod+Ctrl+Shift+${toString i}".action.move-column-to-workspace = ws;
                }
              ) 10
            ));

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          workspaces = {
            "spotify" = { };
          };

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
              background-effect = {
                blur = true;
              };
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
                {
                  app-id = "zen";
                }
                {
                  app-id = "brave";
                }
                {
                  app-id = "xdg-desktop-portal-gtk";
                }
              ];
              scroll-factor = 0.9;
            }
            {
              matches = [
                {
                  app-id = "zen";
                }
                {
                  app-id = "brave";
                }
              ];
              open-maximized = true;
            }
            {
              matches = [
                {
                  title = "^Picture-in-Picture$";
                }
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
                {
                  title = "Discord Popout";
                }
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
                {
                  app-id = "pavucontrol";
                }
                {
                  app-id = "pavucontrol-qt";
                }
                {
                  app-id = "com.saivert.pwvucontrol";
                }
                {
                  app-id = "io.github.fsobolev.Cavalier";
                }
                {
                  app-id = "dialog";
                }
                {
                  app-id = "popup";
                }
                {
                  app-id = "task_dialog";
                }
                {
                  app-id = "gcr-prompter";
                }
                {
                  app-id = "file-roller";
                }
                {
                  app-id = "org.gnome.FileRoller";
                }
                {
                  app-id = "nm-connection-editor";
                }
                {
                  app-id = "blueman-manager";
                }
                {
                  app-id = "xdg-desktop-portal-gtk";
                }
                {
                  app-id = "org.kde.polkit-kde-authentication-agent-1";
                }
                {
                  app-id = "pinentry";
                }
                {
                  title = "Progress";
                }
                {
                  title = "File Operations";
                }
                {
                  title = "Confirm";
                }
                {
                  title = "Error";
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
            }
          ];

          layer-rules = [
            {
              matches = [
                {
                  namespace = "^noctalia-wallpaper*";
                }
              ];
              place-within-backdrop = true;
            }
          ];

          spawn-at-startup = [
            # { command = [ noctaliaExe ]; }
            { command = [ (getExe config.programs.dank-material-shell.package) ]; }
          ]
          ++ optionals config.programs.nixcord.vesktop.enable [
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
