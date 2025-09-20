# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      # packages = {
      #   koshi = pkgs.callPackage ./ags { inherit inputs; };
      # };
    };
}
