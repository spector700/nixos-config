{ inputs, ... }:
{
  flake.aspects.dms.homeManager =
    {
      lib,
      location,
      config,
      osConfig,
      self,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkMerge optionalAttrs splitString;
    in
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
      ];

      config = mkMerge [
        {
          home.packages = with pkgs; [
            dux-gop
            adw-gtk3
          ];

          # Keep the root real: DMS's plugin manager passes plugin paths to go-git,
          # which rejects a symlinked plugins directory.
          home.activation.dmsConfigLink =
            let
              # Makes the config relative to this file
              configPath = lib.removePrefix "${self.outPath}/" (toString ./_config);
            in
            lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              TARGET="$HOME/.config/dms"
              SOURCE=${lib.escapeShellArg "${location}/${configPath}"}
              PLUGINS_SOURCE="$SOURCE/plugins"

              if [ -L "$TARGET" ]; then
                unlink "$TARGET"
              elif [ -e "$TARGET" ] && [ ! -d "$TARGET" ]; then
                printf 'error: %s exists and is not a directory\n' "$TARGET" >&2
                exit 1
              fi
              mkdir -p "$TARGET"

              link_entry() {
                source="$SOURCE/$1"
                target="$TARGET/$1"
                if [ -L "$target" ]; then
                  if [ "$(readlink "$target")" = "$source" ]; then
                    return
                  fi
                  unlink "$target"
                elif [ -e "$target" ]; then
                  return
                fi
                ln -s "$source" "$target"
              }

              for entry in .firstlaunch clsettings.json plugin_settings.json plugins.lock.json settings.json themes zen.css; do
                link_entry "$entry"
              done

              PLUGINS_TARGET="$TARGET/plugins"
              if [ -L "$PLUGINS_TARGET" ]; then
                unlink "$PLUGINS_TARGET"
              elif [ -e "$PLUGINS_TARGET" ] && [ ! -d "$PLUGINS_TARGET" ]; then
                printf 'error: %s exists and is not a directory\n' "$PLUGINS_TARGET" >&2
                exit 1
              fi
              mkdir -p "$PLUGINS_TARGET"

              for source in "$PLUGINS_SOURCE"/* "$PLUGINS_SOURCE"/.[!.]*; do
                [ -e "$source" ] || [ -L "$source" ] || continue
                [ "$(basename "$source")" = ".repos" ] && continue
                target="$PLUGINS_TARGET/$(basename "$source")"
                [ -e "$target" ] || [ -L "$target" ] || ln -s "$source" "$target"
              done
            '';

          programs.dank-material-shell = {
            enable = true;
            enableDynamicTheming = true;

            systemd = {
              enable = true;
              restartIfChanged = true;
            };
          };

          # Force Themeing
          gtk = {
            gtk3.extraCss = ''
              @import url("${config.xdg.configHome}/gtk-3.0/dank-colors.css");
            '';

            gtk4.extraCss = ''
              @import url("${config.xdg.configHome}/gtk-4.0/dank-colors.css");
            '';
          };
        }
        (optionalAttrs (osConfig.programs.niri.enable or false) {
          systemd.user.services.niri-flake-polkit.enable = false;

          programs.niri =
            let
              dms =
                cmd:
                [
                  "dms"
                  "ipc"
                  "call"
                ]
                ++ (splitString " " cmd);
            in
            {
              settings = {
                switch-events.lid-close.action.spawn = dms "lock lock";

                layer-rules = [

                  # Hide DMS notification popups from screencast captures
                  {
                    matches = [
                      { namespace = "^dms:notification-popup$"; }
                    ];
                    block-out-from = "screencast";
                  }
                ];

                binds = {
                  "Mod+Space".action.spawn = dms "spotlight toggle";
                  "Mod+V".action.spawn = dms "clipboard toggle";
                  "Ctrl+Alt+Delete".action.spawn = dms "session toggle";
                  "Mod+Escape".action.spawn = dms "lock lock";
                  "Mod+Comma".action.spawn = dms "settings toggle";
                  # "Print".action.spawn = dms "niri screenshot";

                  "XF86AudioPlay" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "playPause"
                    ];
                  };

                  "XF86AudioPause" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "playPause"
                    ];
                  };

                  "XF86AudioNext" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "next"
                    ];
                  };

                  "XF86AudioPrev" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "previous"
                    ];
                  };

                  "XF86AudioStop" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "stop"
                    ];
                  };
                };
              };
            };
        })

        (optionalAttrs (osConfig.programs.hyprland.enable or false) {
          wayland.windowManager.hyprland = {
            extraConfig = ''
              require("dms.colors")
              require("dms.layout")
              require("dms.windowrules")
            '';

            extraLuaFiles."nix/dms-binds" = ''
              hl.bind("SUPER + comma", hl.dsp.exec_cmd("dms ipc call settings toggle"))
              hl.bind("SUPER + L", hl.dsp.exec_cmd("dms ipc call lock lock"))
              hl.bind("SUPER + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
              hl.bind("SUPER + space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
            '';

          };
        })
      ];
    };
}
