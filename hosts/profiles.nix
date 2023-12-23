{ inputs, nixpkgs, system, home-manager, user, location, ... }:

{
  # Desktop profile
  desktop = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs system user location;
    };
    # Pass flake variable
    # Modules that are used
    modules = [
      inputs.gaming.nixosModules.pipewireLowLatency
      inputs.nh.nixosModules.default
      ./desktop
      ../modules/core
      ../modules/desktop.nix
      ../modules/greetd.nix
      ../modules/hardware.nix
      ../modules/printing.nix
      ../modules/programs/games.nix
      ../modules/programs/thunar.nix

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
            ./desktop/home.nix
            ../home-modules
            ../home-modules/wayland
            ../home-modules/programs
            ../home-modules/editors/neovim
            ../home-modules/shell
          ];
        };
      }
    ];
  };
}
