_: {
  flake.aspects = { aspects, ... }: {
    alfheim = {
      includes = with aspects; [
        hyprland
        git
        ssh
        user
      ];

      nixos = { };
      homeManager = { };
    };
  };
}
