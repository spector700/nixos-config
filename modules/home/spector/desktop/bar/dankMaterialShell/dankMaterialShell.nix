{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.modules.desktop.bar;
in
{
  imports = [ inputs.dankMaterialShell.homeModules.dank-material-shell ];

  config = mkIf (cfg == "dankMaterialShell") {
    programs.dank-material-shell = {
      enable = true;
      systemd = {
        enable = true;
        restartIfChanged = true;
      };
      enableClipboardPaste = false;
      enableDynamicTheming = true;

      # settings = (import ./settings.nix) // {
      #   theme = "dark";
      #
      #   # Host-specific: laptop gets battery/brightness widgets, desktop does not
      #   showBattery = osConfig.modules.roles.laptop.enable;
      #   controlCenterShowBrightnessIcon = osConfig.modules.roles.laptop.enable;
      #   controlCenterShowBrightnessPercent = osConfig.modules.roles.laptop.enable;
      #   hideBrightnessSlider = !osConfig.modules.roles.laptop.enable;
      #
      #   # Disable matugen templates for apps not in this config
      #   matugenTemplateNiri = false;
      #   matugenTemplateMangowc = false;
      #   matugenTemplateFoot = false;
      #   matugenTemplateAlacritty = false;
      #   matugenTemplateWezterm = false;
      #   matugenTemplateEmacs = false;
      # };
    };

    wayland.windowManager.hyprland = {
      settings = {
        bind = [
          "$mod, comma, exec, dms ipc call settings toggle"
          "$mod CTRL, q, exec, dms ipc call lock lock"
          "$mod, P, exec, dms ipc call clipboard toggle"
        ];

        windowrule = [
          "float on, match:class org.quickshell"
        ];
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
