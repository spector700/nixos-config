# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ inputs, pkgs, ... }:
let
  koshi = pkgs.callPackage ./ags { inherit inputs; };
in
{
  # inherit (koshi.desktop) config;
  config = koshi.desktop.config;
  default = koshi.desktop.script;
  greeter = koshi.greeter.script;
}
