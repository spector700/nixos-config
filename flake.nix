{
  description = "Nixos System Configuration";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # CachyOS Kernel
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland.url = "git+https://github.com/hyprwm/Hyprland/?submodules=1/d26439a0fe5594fb26d5a3c01571f9490a9a2d2c";

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

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # quickshell = {
    #   url = "git+https://git.outfoxxed.me/outfoxxed/quickshell?submodules=1&rev=00858812f25b748d08b075a0d284093685fa3ffd";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Color theming
    stylix.url = "github:danth/stylix";
    # persist files on boot
    impermanence.url = "github:nix-community/impermanence";
    # create nix project automatically
    dev-assistant.url = "github:spector700/DevAssistant";
    # My app launcher
    lumastart.url = "github:spector700/lumastart";
    # my neovim flake
    Akari.url = "github:spector700/Akari";
    # gaming tweaks and addons
    gaming.url = "github:fufexan/nix-gaming";
    # FFxiv
    xivlauncher-rb.url = "github:drakon64/nixos-xivlauncher-rb";
    # star citizen
    nix-citizen.url = "github:LovingMelody/nix-citizen";
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
