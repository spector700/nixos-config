{
  inputs,
  self,
  location,
  lib',
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem optional;

  mkHost =
    host:
    {
      homeManager ? false,
    }:
    nixosSystem {
      specialArgs = {
        inherit
          inputs
          self
          lib'
          location
          ;
      };

      modules = [
        self.modules.nixos.${host}
      ]
      ++ optional homeManager {
        home-manager.users.spector.imports = [
          self.modules.homeManager.${host}
        ];
      };
    };
in
{
  # Desktop
  alfheim = mkHost "alfheim" { homeManager = true; };
  # Laptop
  vivo = mkHost "vivo" { homeManager = true; };
  # VPS
  vanaheim = mkHost "vanaheim" { homeManager = true; };
}
