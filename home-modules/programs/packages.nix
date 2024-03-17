{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # Terminal Utils
      neofetch
      wget

      # Video/Audio
      mpv
      loupe
      celluloid
      pavucontrol
      gimp

      vesktop
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
