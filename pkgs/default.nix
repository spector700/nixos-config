# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ inputs, pkgs, ... }:
let
  koshi = pkgs.callPackage ./ags { inherit inputs; };
in
{
  default = koshi;
}
