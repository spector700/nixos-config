{ inputs, lib, home-manager, user, location, ... }:
{
  # Desktop profile
  alfhiem = lib.nixosSystem {
    specialArgs = {
      inherit inputs user location;
    };
    # Modules that are used
    modules = [
      ./alfhiem
      ../modules/core
      ../modules/desktop.nix
      ../modules/greetd.nix
      ../modules/modules.nix
      ../modules/programs/games.nix
      ../modules/programs/thunar.nix

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
              ./alfhiem/home.nix
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
      ../modules/modules.nix

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
