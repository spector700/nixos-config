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
    { nixpkgs.overlays = [ inputs.hyprpanel.overlay ]; }
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
  alfhiem = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ./alfhiem
      ../modules/nixos
    ] ++ concatLists [ homeManager ];
  };

  # VM
  vm = nixosSystem {
    inherit specialArgs;
    # Modules that are used
    modules = [
      ./vm
      ../modules/nixos
    ] ++ concatLists [ homeManager ];
  };
}
