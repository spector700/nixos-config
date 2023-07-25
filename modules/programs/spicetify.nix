{ inputs, ... }:
{

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.packages.default;
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin-mocha;
      colorScheme = "flamingo";
      enabledExtensions = with spicePkgs.extensions; [
        hidePodcasts
        fullAppDisplay
      ];
    };
}
