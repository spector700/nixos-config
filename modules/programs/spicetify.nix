{ inputs, pkgs, ... }:
{

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.Blossom;
      injectCss = true;
      overwriteAssets = true;
      colorScheme = "dark";
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
