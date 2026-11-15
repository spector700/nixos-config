{
  inputs,
  self,
  location,
  lib',
  ...
}:
let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  specialArgs = {
    inherit
      inputs
      self
      lib'
      location
      ;
  };
in
{
  # Desktop
  alfheim = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ../modules/nixos
      self.modules.nixos.alfheim
      {
        home-manager.users.spector.imports = [ self.modules.homeManager.alfheim ];
      }
    ];
  };

  # Laptop
  vivo = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ../modules/nixos
      self.modules.nixos.vivo
      {
        home-manager.users.spector.imports = [ self.modules.homeManager.vivo ];
      }
    ];
  };

  # Homelab
  vanaheim = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ./vanaheim
      ../modules/nixos
    ];
  };

  # minimal build for initial install
  minimal = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ./minimal
      ../modules/nixos
    ];
  };
}
