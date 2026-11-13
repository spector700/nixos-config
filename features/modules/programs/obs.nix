_: {
  flake.aspects.obs.homeManager = { pkgs, ... }: {

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-composite-blur
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
  };
}
