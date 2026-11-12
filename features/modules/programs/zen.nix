{ inputs, ... }:
{
  flake.aspects.zen.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default ];
    };
}
