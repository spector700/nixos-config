{
  imports = [
    ./kitty.nix
    ./rofi
    ./spicetify.nix
    ./packages.nix
    ./qt.nix
    ./gtk.nix
    ./zathura.nix
    ./lf.nix
    ./xdg.nix
  ];

  programs = {
    firefox.enable = true;
    brave.enable = true;
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = true;
    };
  };
}
