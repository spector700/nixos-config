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
          nixfmt-rfc-style.enable = true;
          statix.enable = true;

          shellcheck.enable = true;

          shfmt.enable = true;
        };
      };
    };
}
