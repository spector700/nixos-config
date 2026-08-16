{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.modules.desktop.bar;
in
{
  imports = [
    inputs.dankMaterialShell.homeModules.dank-material-shell
    inputs.dankMaterialShell.homeModules.niri
  ];

  config = mkIf (cfg == "dankMaterialShell") {
    home.packages = with pkgs; [
      dgop
    ];

    # Keep the root real: DMS's plugin manager passes plugin paths to go-git,
    # which rejects a symlinked plugins directory.
    home.activation.dmsConfigLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      TARGET="$HOME/.config/DankMaterialShell"
      SOURCE="$HOME/nixos-config/modules/home/spector/desktop/bar/dankMaterialShell/config"

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

      for source in "$SOURCE/plugins"/* "$SOURCE/plugins"/.[!.]*; do
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

      niri.includes = {
        enable = true;
        override = true;
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          "layout"
          "outputs"
          "windowrules"
          "blur"
          "wpblur"
        ];
        originalFileName = "hm";
      };
    };

    programs.niri =
      let
        dms =
          cmd:
          [
            "dms"
            "ipc"
            "call"
          ]
          ++ (lib.splitString " " cmd);
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

    wayland.windowManager.hyprland = {
      settings = {
        bind = [
          "$mod, comma, exec, dms ipc call settings toggle"
          "$mod, L, exec, dms ipc call lock lock"
          "$mod, V, exec, dms ipc call clipboard toggle"
          "$mod, space, exec, dms ipc call spotlight toggle"
        ];
      };
    };

  };
}
