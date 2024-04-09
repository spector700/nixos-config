{
  imports = [
    ./browsers
    ./rofi
    ./vesktop
    ./kitty.nix
    ./gtk.nix
    ./packages.nix
    ./spicetify.nix
    ./xdg.nix
    ./zathura.nix
  ];

  programs = {
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = true;
    };
  };
}
