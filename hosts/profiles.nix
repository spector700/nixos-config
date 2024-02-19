{ inputs, lib, home-manager, user, location, ... }:

{
  # Desktop profile
  desktop = lib.nixosSystem {
    specialArgs = {
      inherit inputs user location;
    };
    # Modules that are used
    modules = [
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
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit user inputs location;
          };
          users.${user} = {
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
        };
      }
    ];
  };
  # vm profile
  vm = lib.nixosSystem {
    specialArgs = {
      inherit inputs user location;
    };
    # Modules that are used
    modules = [
      ./vm
      ../modules/core

      # Home-Manager module that is used.

      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit user inputs location;
          };
          users.${user} = {
            imports = [
              inputs.dev-assistant.homeManagerModules.default
              ../home-modules
              ../home-modules/programs/kitty.nix
              ../home-modules/editors/neovim
              ../home-modules/shell
            ];
          };
        };
      }
    ];
  };
}
