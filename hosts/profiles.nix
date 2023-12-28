{ inputs, nixpkgs, system, home-manager, user, location, ... }:

{
  # Desktop profile
  desktop = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs system user location;
    };
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
      ../modules/virtualisation.nix

      # Home-Manager module that is used.

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user inputs location;
        };
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
  # vm profile
  vm = nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs system user location;
    };
    # Modules that are used
    modules = [
      inputs.gaming.nixosModules.pipewireLowLatency
      inputs.nh.nixosModules.default
      ./vm
      ../modules/core
      ../modules/desktop.nix
      ../modules/greetd.nix
      ../modules/hardware.nix
      ../modules/programs/games.nix
      ../modules/programs/thunar.nix

      # Home-Manager module that is used.

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit user inputs location;
        };
        home-manager.users.${user} = {
          imports = [
            inputs.anyrun.homeManagerModules.default
            inputs.spicetify.homeManagerModules.default
            inputs.dev-assistant.homeManagerModules.default
            ./vm/home.nix
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
