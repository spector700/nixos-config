{ inputs, pkgs, ... }:
{

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify.packages.${pkgs.system}.default;
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin-mocha;
      colorScheme = "lavender";
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
        keyboardShortcut
        shuffle
      ];
      enabledCustomApps = with spicePkgs.apps; [
        reddit
      ];
    };
}
