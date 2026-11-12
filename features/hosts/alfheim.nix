_: {
  flake.aspects = { aspects, ... }: {
    alfheim = {
      includes = with aspects; [
        hyprland
        ssh
        bluetooth
        printing
        sound
        core
        impermanence
      ];

      nixos = { };
      homeManager = { };
    };
  };
}
