{ moduleWithSystem, ... }:
{
  flake.aspects.neovim = {
    nixos = {
      environment.variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        SUDO_EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
      };
    };

    homeManager = moduleWithSystem (
      { inputs', ... }:
      {
        home.packages = [ inputs'.Akari.packages.default ];
      }
    );
  };
}
