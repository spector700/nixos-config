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

    dev-assistant = {
      url = "github:spector700/DevAssistant";
    };

    Akari = {
      url = "github:spector700/Akari";
    };

    anyrun = {
      url = "github:Kirottu/anyrun";
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

    ags = {
      url = "github:Aylur/ags";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      user = "nick";
      # Location of the nixos config
      location = "/home/${user}/.config/nixos-config";
      system = "x86_64-linux";
    in
    {

      # NixOS configurations
      nixosConfigurations = import ./hosts/profiles.nix {
        inherit inputs nixpkgs system home-manager user location;
      };

      # Non-NixOS configurations
      #homeConfigurations = (
      #import ./nix {
      #inherit (nixpkgs) lib;
      #inherit inputs nixpkgs nixpkgs-stable home-manager user;
      #}
      #);
    };
}
