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
      self.modules.nixos.vanaheim
      {
        home-manager.users.spector.imports = [ self.modules.homeManager.vanaheim ];
      }
    ];
  };
}
