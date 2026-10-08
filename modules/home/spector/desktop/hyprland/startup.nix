{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  uexec = program: "uwsm app -- ${program}";
  inherit (config.modules.desktop) bar;
  inherit (lib) optionals getExe;
in
{
  wayland.windowManager.hyprland = {
    extraLuaFiles."nix/startup" = builtins.concatStringsSep "\n" (
      [
        ''
          hl.on("hyprland.start", function()
            hl.exec_cmd("wl-paste --watch cliphist store")
            hl.exec_cmd("hyprctl dispatch workspace 1")
        ''
      ]
      ++ optionals (bar != "dankMaterialShell") [
        ''hl.exec_cmd("${getExe pkgs.wlsunset} -l 32.7 -L -96.9")''
      ]
      ++ optionals config.programs.nixcord.vesktop.enable [
        ''hl.exec_cmd("sleep 9 && ${uexec "vesktop"}")''
      ]
      ++ optionals config.modules.programs.spicetify.enable [
        ''hl.exec_cmd("${uexec (getExe config.modules.programs.spicetify.spicedSpotify)}")''
      ]
      ++ optionals osConfig.programs.steam.enable [
        ''hl.exec_cmd("${uexec "steam"}")''
      ]
      ++ [ "end)" ]
    );
  };
}
