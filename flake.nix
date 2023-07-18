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

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
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

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, home-manager, hyprland, gaming, ... }:
    let 
      user="nick";
      location = "$HOME/.setup";
    in {

      # NixOS configurations
      nixosConfigurations = (
        # Imports ./hosts/default.nix
        import ./hosts {
            inherit (nixpkgs) lib;
            inherit inputs nixpkgs nixpkgs-stable home-manager user location hyprland gaming;
        }
      );

      # Non-NixOS configurations
      #homeConfigurations = (
        #import ./nix {
            #inherit (nixpkgs) lib;
            #inherit inputs nixpkgs nixpkgs-stable home-manager user;
        #}
      #);

    };
}
