{
  pkgs,
  inputs,
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
    vial

    inputs.niri-scratchpad.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
