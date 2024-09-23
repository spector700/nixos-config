{
  imports = [
    ./browsers
    ./rofi
    ./vesktop
    ./kitty.nix
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
