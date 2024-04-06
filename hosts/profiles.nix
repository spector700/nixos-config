{ inputs, self, lib, location, lib', ... }:
let
  hm = inputs.home-manager.nixosModules.home-manager;
  homesDir = ../home-modules; # home-manager configurations for hosts that need home-manager
  homeManager = [ hm homesDir ]; # combine hm flake input and the home module to be imported together
in
{
  # Desktop profile
  alfhiem = lib.nixosSystem {
    specialArgs = {
      inherit inputs self location lib';
    };
    # Modules that are used
    modules = [
      ./alfhiem
      ../modules
      ../modules/programs/thunar.nix
      inputs.disko.nixosModules.disko

    ] ++ lib.concatLists [ homeManager ];
  };
  # vm profile
  vm = lib.nixosSystem {
    specialArgs = {
      inherit inputs self location;
    };
    # Modules that are used
    modules = [
      ./vm
      ../modules

    ] ++ lib.concatLists [ homeManager ];
  };
}
