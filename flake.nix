#
#  flake.nix *             
#   ├─ ./hosts
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix
#

{
  description = "Nixos System Configuration";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gaming = {
      url = "github:fufexan/nix-gaming";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, hyprland, gaming, ... }:
    let 
      user="nick";
      location = "$HOME/.setup";
    in {

      # NixOS configurations
      nixosConfigurations = (
        # Imports ./hosts/default.nix
        import ./hosts {
            inherit (nixpkgs) lib;
            inherit inputs nixpkgs nixpkgs-unstable home-manager user location hyprland gaming;
        }
      );

      # Non-NixOS configurations
      #homeConfigurations = (
        #import ./nix {
            #inherit (nixpkgs) lib;
            #inherit inputs nixpkgs nixpkgs-unstable home-manager user;
        #}
      #);

    };
}
