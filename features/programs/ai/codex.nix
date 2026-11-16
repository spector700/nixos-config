{ moduleWithSystem, ... }: {
  flake.aspects = { aspects, ... }: {
    codex = {
      includes = [ aspects.ai-tools ];

      homeManager = moduleWithSystem (
        { inputs', ... }:
        {
          home.packages = [ inputs'.codex-desktop-linux.packages.default ];
        }
      );
    };
  };
}
