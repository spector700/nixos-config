{ config, lib, pkgs, inputs, user, location, system, ... }: {
  # configuration used by all hosts

  imports = [
    ./nix.nix
    ./network.nix
    ./security.nix
  ];

  users.users.${user} = {
    # System User
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh; # Default shell
  };

  time.timeZone = "America/Chicago"; # Time zone and internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      # Extra locale settings that need to be overwritten
      LC_TIME = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkDefault true;
        configurationLimit = 10;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    # Boot logo
    plymouth = {
      enable = true;
      theme = "breeze";
    };
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting = {
        enable = true;
        patterns = { "rm -rf *" = "fg=black,bg=red"; };
        styles = { "alias" = "fg=blue"; };
        highlighters = [ "main" "brackets" "pattern" ];
      };
    };

    direnv = {
      enable = true;
      silent = true;
    };

    dconf.enable = true;
  };

  console = {
    font = "ter-v20n";
    packages = [ pkgs.terminus_font ];
    keyMap = "us";
  };

  security.sudo.wheelNeedsPassword = lib.mkDefault false; # User does not need to give password when using sudo.


  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    pathsToLink = [ "/share/zsh" ];
  };


  # For `info` command.
  documentation.info.enable = false;
  # NixOS manual and such.
  documentation.nixos.enable = false;
  # Useless with flakes (without configuring)
  programs.command-not-found.enable = false;

}
