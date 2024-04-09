{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Terminal Utils
    fastfetch

    # Video/Audio
    mpv
    loupe
    celluloid
    pavucontrol
    gimp

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
}
