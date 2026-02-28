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

  inherit (config.lib.stylix) colors;
in
{
  imports = [ inputs.dankMaterialShell.homeModules.dank-material-shell ];

  config = mkIf (cfg == "dankMaterialShell") {
    # stylix.targets.dank-material-shell.enable = false;

    # home.sessionVariables = {
    #   DMS_DISABLE_MATUGEN = "1";
    # };

    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      # enableBrightnessControl = mkIf config.modules.roles.laptop.enable;
      enableClipboardPaste = false;
      enableDynamicTheming = true;

      settings = (import ./settings.nix) // {
      };
    };

    # xdg.configFile."DankMaterialShell/stylix-colors.json".text = builtins.toJSON colorTheme;

    wayland.windowManager.hyprland = {
      settings = {
        # exec-once = [
        #   "sleep 2 && dms run"
        # ];

        bind = [
          "$mod, comma, exec, dms ipc call settings toggle"
          "$mod CTRL, q, exec, dms ipc call lock lock"

          # "$mod, Space, exec, dms ipc call spotlight toggle"
          "$mod, P, exec, dms ipc call clipboard toggle"
        ];

        windowrule = [
          "float on, match:class org.quickshell"
        ];
        "$blur_layer" = "dms:(color-picker|clipboard|spotlight|settings)";
        layerrule = [
          "blur on, match:namespace dms:.*"
          "ignore_alpha 0, match:namespace dms:.*"

          "animation slide right, match:namespace dms:control-center"
          "animation slide top, match:namespace dms:workspace-overview"

          "no_anim on, match:namespace ^(quickshell)$"
        ];
      };
    };

  };
}
