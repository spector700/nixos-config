{
  inputs,
  self,
  location,
  lib',
  ...
}:
let
  inherit (inputs.nixpkgs.lib) concatLists nixosSystem;

  hm = inputs.home-manager.nixosModules.home-manager;
  homesDir = ../home-modules; # home-manager configurations for hosts that need home-manager
  homeManager = [
    hm
    homesDir
  ]; # combine hm flake input and the home module to be imported together

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
  # Desktop profile
  alfhiem = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ./alfhiem
      ../modules
    ] ++ concatLists [ homeManager ];
  };

  # vm profile
  vm = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ./vm
      ../modules
    ] ++ concatLists [ homeManager ];
  };
}
