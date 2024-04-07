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

    # declareable filesystem
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # pretty nixos rebuild
    nh = {
      url = "github:viperML/nh";
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

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib // home-manager.lib;
      lib' = import ./lib;
      user = "spector";
      # Location of the nixos config
      location = "/home/${user}/nixos-config";
      systems = [ "x86_64-linux" "aarch64-linux" ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
      });
    in
    {
      # NixOS configurations
      nixosConfigurations = import ./hosts/profiles.nix {
        inherit inputs self lib lib' home-manager location;
      };

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; inherit inputs; });


      # Non-NixOS configurations
      #homeConfigurations = (
      #import ./nix {
      #inherit (nixpkgs) lib;
      #inherit inputs nixpkgs nixpkgs-stable home-manager user;
      #}
      #);
    };
}
