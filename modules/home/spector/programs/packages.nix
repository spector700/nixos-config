{
  inputs,
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
    gimp

    signal-desktop
    obsidian
    anki
    vial
    lmstudio

    inputs.lumastart.packages.${pkgs.system}.default
  ];
}
