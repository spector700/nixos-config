_: {
  flake.aspects = { aspects, ... }: {
    alfheim = {
      includes = with aspects; [ hyprland ];

      nixos = { };
      homeManager = { };
    };
  };
}
