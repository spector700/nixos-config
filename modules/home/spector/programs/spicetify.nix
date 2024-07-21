{ inputs, pkgs, ... }:
{
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.blossom;
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
        keyboardShortcut
        shuffle
      ];
      enabledCustomApps = with spicePkgs.apps; [ reddit ];
    };
}
