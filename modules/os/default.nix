{ pkgs, ... }:
{
  # configuration used by all hosts

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

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
    };

    dconf.enable = true;
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
