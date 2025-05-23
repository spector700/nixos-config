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
    ../modules/home # home-manager configurations for hosts that need home-manager
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
    ] ++ concatLists [ homeManager ];
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
}
