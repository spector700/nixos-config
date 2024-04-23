{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./user.nix
  ];

  time.timeZone = "America/Chicago"; # Time zone and internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      # Extra locale settings that need to be overwritten
      LC_TIME = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
    };
  };

  # also have to enable the nixos zsh if using the home-manager one
  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
    };

    dconf.enable = true;

    direnv = {
      enable = true;
      silent = true;

      # move the .direnv folder to a cache location
      direnvrcExtra = ''
        : ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs

        # https://github.com/direnv/direnv/wiki/Customizing-cache-location#hashed-directories
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
            echo -n "$XDG_CACHE_HOME"/direnv/layouts/
            echo -n "$PWD" | ${pkgs.perl}/bin/shasum | cut -d ' ' -f 1
          )}"
        }
      '';
    };
  };

  console = {
    font = "ter-powerline-v18n";
    packages = with pkgs; [
      terminus_font
      powerline-fonts
    ];
    keyMap = "us";
  };

  environment = {
    # packages that will be shared across all users and and all systems
    systemPackages = with pkgs; [
      git
      curl
      wget
    ];

    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
      MANPAGER = "nvim +Man!";
    };

    pathsToLink = [ "/share/zsh" ];
  };
}
