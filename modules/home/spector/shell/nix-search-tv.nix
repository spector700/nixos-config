{ pkgs, ... }:
{
  # Enable nix-search-tv with 'ns';
  home.packages = with pkgs; [
    (writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
      ];
      text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
    })
  ];
}
