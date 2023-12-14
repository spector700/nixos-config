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

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify = {
      url = "github:/Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gaming = {
      url = "github:fufexan/nix-gaming";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, home-manager, gaming, hyprland-contrib, nh, ... }:
    let
      user = "nick";
      # Location of the nixos config
      location = "/home/${user}/.config/nixos-config";
    in
    {

      # NixOS configurations
      nixosConfigurations = (
        # Imports ./hosts/default.nix
        import ./hosts/profiles.nix {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-stable home-manager user location gaming nh;
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
