{
  description = "Nixos System Configuration";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # app launcher
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # my sops-nix private repo
    nix-secrets = {
      url = "git+ssh://git@github.com/spector700/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };

    # declareable filesystem
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # A tree-wide formatter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # database for comma
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # custom spotify
    spicetify = {
      url = "github:/Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # get colors from wallpaper
    matugen = {
      url = "github:InioX/matugen";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # bar
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # persist files on boot
    impermanence.url = "github:nix-community/impermanence";
    # create nix project automaticly
    dev-assistant.url = "github:spector700/DevAssistant";
    # My app launcher
    lumastart.url = "github:spector700/lumastart";
    # my neovim flake
    Akari.url = "github:spector700/Akari";
    # gaming tweaks and addons
    gaming.url = "github:fufexan/nix-gaming";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    let
      # custom lib functions
      lib' = import ./lib;
      # main user for location
      user = "spector";
      # Location of the nixos config
      location = "/home/${user}/nixos-config";
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      # systems for which the `perSystem` attributes will be built
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule

        # the flake utilities
        ./flake
        ./pkgs
      ];

      flake = {
        # entry-point for nixosConfigurations
        nixosConfigurations = import ./hosts/profiles.nix {
          inherit
            inputs
            self
            lib'
            location
            ;
        };
      };
    };
}
