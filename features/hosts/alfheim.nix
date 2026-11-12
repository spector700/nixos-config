_: {
  flake.aspects = { aspects, ... }: {
    alfheim = {
      includes = with aspects; [
        hyprland
        git
        ssh
      ];

      nixos = { };
      homeManager = { };
    };
  };
}
