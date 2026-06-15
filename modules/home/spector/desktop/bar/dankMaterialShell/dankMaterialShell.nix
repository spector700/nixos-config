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

    # Symlink ~/.config/DankMaterialShell/ → repo config/ so the DMS GUI
    # writes directly to the repo. Git tracks every settings change.
    home.activation.dmsConfigLink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      TARGET="$HOME/.config/DankMaterialShell"
      if [ -e "$TARGET" ] && [ ! -L "$TARGET" ]; then
        rm -rf "$TARGET"
      fi
      ln -sfn "$HOME/nixos-config/modules/home/spector/desktop/bar/dankMaterialShell/config" "$TARGET"
    '';

    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      niri.includes = {
        enable = true;
        filesToInclude = [
          "alttab"
          "binds"
          "colors"
          "layout"
          "outputs"
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

          binds = {
            "Mod+Space".action.spawn = dms "spotlight toggle";
            "Mod+V".action.spawn = dms "clipboard toggle";
            "Ctrl+Alt+Delete".action.spawn = dms "session toggle";
            "Mod+Escape".action.spawn = dms "lock lock";
            "Mod+Comma".action.spawn = dms "settings toggle";
            # "Print".action.spawn = dms "niri screenshot";
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

        # windowrule = [
        #   "float on, match:class org.quickshell"
        # ];
        # layerrule = [
        #   "blur on, match:namespace dms:.*"
        #   "ignore_alpha 0, match:namespace dms:.*"
        #
        #   "animation slide right, match:namespace dms:control-center"
        #   "animation slide top, match:namespace dms:workspace-overview"
        #
        #   "no_anim on, match:namespace ^(quickshell)$"
        # ];
      };
    };

  };
}
