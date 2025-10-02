{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # Terminal Utils
    fastfetch

    # Video/Audio
    mpv
    loupe
    celluloid
    pwvucontrol

    signal-desktop
    obsidian
    anki
    vial
  ];
}
