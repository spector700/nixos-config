{ moduleWithSystem, ... }:
{
  flake.aspects.neovim.homeManager = moduleWithSystem (
    { inputs', ... }:
    {
      home.packages = [ inputs'.Akari.packages.default ];
    }
  );
}
