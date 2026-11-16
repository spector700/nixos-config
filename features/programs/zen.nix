{ moduleWithSystem, ... }:
{
  flake.aspects.zen.homeManager = moduleWithSystem (
    { inputs', ... }:
    {
      home.packages = [ inputs'.zen-browser.packages.default ];
    }
  );
}
