{
  inputs,
  lib,
  config,
  pkgs,
  location,
  ...
}:
let
  inherit (lib) getExe mkIf;
  cfg = config.modules.desktop.bar;
  noctalia = getExe config.programs.noctalia.package;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  config = mkIf (cfg == "noctalia") {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };

    # The plugin starts OpenCode and invokes Noctalia from the user service.
    # Preserve profile/system commands used by desktop-entry applications.
    systemd.user.services.noctalia.Service.Environment = "PATH=${
      lib.makeBinPath [
        config.programs.opencode.package
        config.programs.noctalia.package
        pkgs.bash
        pkgs.coreutils
      ]
    }:${config.home.profileDirectory}/bin:/run/current-system/sw/bin:/run/wrappers/bin";

    programs = {
      kitty.extraConfig = "include themes/noctalia.conf";

      niri.settings.binds = {
        "Mod+Space".action.spawn = [
          noctalia
          "msg"
          "panel-toggle"
          "launcher"
        ];
        "Mod+V".action.spawn = [
          noctalia
          "msg"
          "panel-toggle"
          "clipboard"
        ];
        "Mod+Shift+S".action.spawn = [
          noctalia
          "msg"
          "panel-toggle"
          "control-center"
        ];
        "Mod+Comma".action.spawn = [
          noctalia
          "msg"
          "settings-toggle"
        ];
        "Alt+Tab".action.spawn = [
          noctalia
          "msg"
          "window-switcher"
        ];
        "Mod+Alt+L".action.spawn = [
          noctalia
          "msg"
          "session"
          "lock"
        ];
      };
    };

    home.file.".local/state/noctalia/settings.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${location}/modules/home/spector/desktop/bar/noctalia/config/settings.toml";
  };
}
