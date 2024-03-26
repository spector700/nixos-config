{
  imports = [
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
    firefox.enable = true;
    # brave.enable = true;
    vscode = {
      enable = true;
      enableExtensionUpdateCheck = true;
    };
  };
}
