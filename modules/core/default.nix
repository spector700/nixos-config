{ pkgs, user, ... }: {
  # configuration used by all hosts

  imports = [
    ./nix.nix
    ./network.nix
    ./system
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

  # Boot logo
  boot.plymouth = {
    enable = true;
    theme = "breeze";
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

    dconf.enable = true;
  };

  console = {
    font = "ter-v20n";
    packages = [ pkgs.terminus_font ];
    keyMap = "us";
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    pathsToLink = [ "/share/zsh" ];
  };
}
