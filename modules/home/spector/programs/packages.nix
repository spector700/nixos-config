{
  inputs,
  pkgs,
  ...
}:
let
  orca-slicer-beta = pkgs.callPackage ../../../../pkgs/orca-slicer-appimage.nix { };
in
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
    anki-bin
    vial
    orca-slicer
    # orca-slicer-beta

    inputs.lumastart.packages.${pkgs.system}.default
  ];
}
