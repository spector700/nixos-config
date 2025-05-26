{
  perSystem =
    { pkgs, config, ... }:
    {
      devShells.default = pkgs.mkShell {
        name = "nixos-config";
        meta.description = "The default development shell for my NixOS configuration";

        NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";

        # packages available in the dev shell
        # inputsFrom = [ config.treefmt.build.devShell ];
        #
        packages = with pkgs; [
          # the treefmt command
          config.treefmt.build.wrapper
          just
          yq-go
        ];
      };
    };
}
