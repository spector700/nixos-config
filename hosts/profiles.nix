#
#  These are the different profiles that can be used when building NixOS.
#
#  flake.nix 
#   └─ ./hosts  
#       ├─ profiles.nix *
#       ├─ core.nix
#       ├─ home.nix
#       └─ ./desktop OR ./laptop
#            ├─ ./default.nix
#            └─ ./home.nix 
#

{ inputs, nixpkgs, nixpkgs-stable, home-manager, user, location, ... }:

let
  system = "x86_64-linux";

  stable = import nixpkgs-stable {
    inherit system;
    # Allow proprietary software
    config.allowUnfree = true;
  };
in
{

  # Desktop profile
  desktop = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs stable system user location;
    };
    # Pass flake variable
    # Modules that are used
    modules = [
      inputs.gaming.nixosModules.pipewireLowLatency
      inputs.nh.nixosModules.default
      ./desktop
      ./core.nix

      # Home-Manager module that is used.

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user inputs location;
        }; # Pass flake variable
        home-manager.users.${user} = {
          imports = [
            inputs.anyrun.homeManagerModules.default
            inputs.spicetify.homeManagerModules.default
            inputs.dev-assistant.homeManagerModules.default
            ./home.nix
            ./desktop/home.nix
          ];
        };
      }
    ];
  };
}
