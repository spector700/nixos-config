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

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hypridle = {
      url = "github:hyprwm/hypridle";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlock = {
      url = "github:hyprwm/hyprlock";
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

    # persist files on boot
    impermanence.url = "github:nix-community/impermanence";
    # get colors from wallpaper
    matugen.url = "github:InioX/matugen";
    # create nix project automaticly
    dev-assistant.url = "github:spector700/DevAssistant";
    # my neovim flake
    Akari.url = "github:spector700/Akari";
    # gaming tweaks and addons
    gaming.url = "github:fufexan/nix-gaming";
    # bar
    ags.url = "github:Aylur/ags";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    let
      # custom lib functions
      lib' = import ./lib;
      # main user
      user = "spector";
      # Location of the nixos config
      location = "/home/${user}/nixos-config";
    in
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    # forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    # pkgsFor = lib.genAttrs systems (system: import nixpkgs { inherit system; });
    # packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs inputs; });
    # devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs inputs; });
    # formatter = forEachSystem (pkgs: import ./fmt.nix { inherit pkgs inputs; });

    flake-parts.lib.mkFlake { inherit inputs; } {
      # systems for which the `perSystem` attributes will be built
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule

        # devShell
        ./shell.nix
        # nix fmt
        ./fmt.nix
        # pre-commit checks that run on 'nix flake check'
        ./pre-commit-hooks.nix
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
