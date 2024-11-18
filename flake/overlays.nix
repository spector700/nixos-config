{
  perSystem =
    {
      inputs',
      config,
      pkgs,
      ...
    }:
    {
      overlays = [
        inputs'.hyprpanel.packages.${pkgs.system}.default
      ];
    };
}
