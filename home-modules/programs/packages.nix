{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # Terminal Utils
      tldr
      neofetch
      wget

      # Video/Audio
      mpv
      loupe
      celluloid
      pavucontrol
      gimp

      # Apps
      webcord
      signal-desktop
      networkmanagerapplet
      nextcloud-client
      obsidian
      anki-bin
      vial

      # File Management
      unzip
      unrar
    ];
  };
}
