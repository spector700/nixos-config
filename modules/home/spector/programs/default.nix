{
  imports = [
    ./browsers
    ./rofi
    ./vesktop
    ./kitty.nix
    ./gtk.nix
    ./packages.nix
    ./spicetify.nix
    ./zathura.nix
  ];

  programs = {
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = true;
    };
  };
}
