_: {
  flake.aspects = { aspects, ... }: {
    core = {
      includes = with aspects; [
        avahi
        bootloader
        fonts
        direnv
        git
        network
        nix
        logrotate
        locale
        sudo
        user
        zsh
      ];

      nixos = { pkgs, ... }: {
        environment = {
          # packages that will be shared across all users and and all systems
          systemPackages = with pkgs; [
            curl
            wget
            unzip
            unrar
          ];
        };

        programs.dconf.enable = true;

        console = {
          font = "ter-powerline-v18n";
          packages = with pkgs; [
            terminus_font
            powerline-fonts
          ];
          keyMap = "us";
        };
      };
    };
  };
}
