{
  perSystem =
    {
      inputs',
      config,
      pkgs,
      ...
    }:
    {
      # provide the formatter for `nix fmt`
      formatter = config.treefmt.build.wrapper;

      treefmt = {
        projectRootFile = "flake.nix";

        programs = {
          # formats .nix files
          nixfmt.enable = true;
          statix.enable = true;
          shfmt.enable = true;
        };
      };
    };
}
