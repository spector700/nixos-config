{ inputs, pkgs, ... }:
{
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
}
