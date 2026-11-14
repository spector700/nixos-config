{
  inputs,
  self,
  location,
  lib',
  ...
}:
let
  inherit (inputs.nixpkgs.lib) concatLists nixosSystem;

  # combine hm flake input and the home module to be imported together
  homeManager = [
    inputs.home-manager.nixosModules.home-manager
  ];

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
      ./alfheim
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
      ./vivo
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
    ]
    ++ concatLists [ homeManager ];
  };

  # minimal build for initial install
  minimal = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ./minimal
      ../modules/nixos
    ]
    ++ concatLists [ homeManager ];
  };
}
