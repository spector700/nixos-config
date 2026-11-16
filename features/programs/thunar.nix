_: {
  flake.aspects.thunar.nixos =
    { pkgs, ... }:
    {
      programs.thunar = {
        enable = true;
        plugins = with pkgs; [
          thunar-volman
          thunar-archive-plugin
          thunar-media-tags-plugin
        ];
      };

      services = {
        tumbler.enable = true;
        gvfs.enable = true;
      };

      environment.systemPackages = with pkgs; [
        file-roller
        unar
      ];
    };
}
