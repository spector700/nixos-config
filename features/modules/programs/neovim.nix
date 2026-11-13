{ inputs, ... }:
{
  flake.aspects.neovim.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.Akari.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };
}
