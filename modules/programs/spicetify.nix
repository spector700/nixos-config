{ inputs, pkgs, ... }:
{

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify.packages.${pkgs.system}.default;
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
