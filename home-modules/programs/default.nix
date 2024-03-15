{
  imports = [
    ./kitty.nix
    ./rofi
    ./spicetify.nix
    ./packages.nix
    ./gtk.nix
    ./zathura.nix
    ./xdg.nix
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
