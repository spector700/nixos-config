{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.programs.spicetify;
  inherit (lib) mkIf mkEnableOption;
in
{
  imports = [ inputs.spicetify.homeManagerModules.spicetify ];

  options.modules.programs.spicetify = {
    enable = mkEnableOption "Enable spicetify";
  };

  config = mkIf cfg.enable {
    programs.spicetify =
      let
        spicePkgs = inputs.spicetify.legacyPackages.${pkgs.system};
      in
      {
        enable = true;
        enabledExtensions = with spicePkgs.extensions; [
          hidePodcasts
          keyboardShortcut
          shuffle
        ];
        enabledCustomApps = with spicePkgs.apps; [ reddit ];
      };
  };
}
