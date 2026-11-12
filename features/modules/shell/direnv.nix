_: {
  flake.aspects.direnv = {
    nixos = { pkgs, ... }: {

      programs = {
        direnv = {
          enable = true;
          silent = true;

          # move the .direnv folder to a cache location
          direnvrcExtra = ''
            : ''${XDG_CACHE_HOME:=$HOME/.cache}
            declare -A direnv_layout_dirs

            # https://github.com/direnv/direnv/wiki/Customizing-cache-location#hashed-directories
            direnv_layout_dir() {
              echo "''${direnv_layout_dirs[$PWD]:=$(
                echo -n "$XDG_CACHE_HOME"/direnv/layouts/
                echo -n "$PWD" | ${pkgs.perl}/bin/shasum | cut -d ' ' -f 1
              )}"
            }
          '';
        };
      };

    };
  };
}
