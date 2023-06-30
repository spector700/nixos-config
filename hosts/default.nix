#
#  These are the different profiles that can be used when building NixOS.
#
#  flake.nix 
#   └─ ./hosts  
#       ├─ default.nix *
#       ├─ configuration.nix
#       ├─ home.nix
#       └─ ./desktop OR ./laptop
#            ├─ ./default.nix
#            └─ ./home.nix 
#

{ lib, inputs, nixpkgs, nixpkgs-unstable, home-manager, user, location, hyprland, gaming, ... }:

let
  system = "x86_64-linux";

  pkgs = import nixpkgs {
    inherit system;
    # Allow proprietary software
    config.allowUnfree = true;
  };

  unstable = import nixpkgs-unstable { 
    inherit system;
    # Allow proprietary software
    config.allowUnfree = true;
  };

in
{
  # Desktop profile
  desktop = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs unstable system user location hyprland gaming;
      host = {
        hostName = "Alfhiem-Nix";
        mainMonitor = "DP-2";
        secondMonitor = "DP-3";
      };
    }; 
    # Pass flake variable
    # Modules that are used
    modules = [  
      hyprland.nixosModules.default
      gaming.nixosModules.default
      ./desktop
      ./configuration.nix

       # Home-Manager module that is used.
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit unstable user;
          host = {
            hostName = "Alfhiem-Nix";     #For Xorg iGPU  | Videocard     | Hyprland iGPU
            mainMonitor = "DP-2"; #HDMIA3         | HDMI-A-1      | HDMI-A-3
            secondMonitor = "DP-3";   #DP1            | DisplayPort-1 | DP-1
          };
        };                                                  # Pass flake variable
        home-manager.users.${user} = {
          imports = [
            ./home.nix
            ./desktop/home.nix
          ];
        };
      }
    ];
  };
}
