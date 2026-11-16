{ inputs, ... }:
{
  flake.aspects.home-manager = {
    nixos =
      {
        self,
        location,
        ...
      }:
      {
        imports = [ inputs.home-manager.nixosModules.home-manager ];

        home-manager = {
          verbose = true;
          backupFileExtension = "backup";
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs self location; };
          # users = lib.genAttrs config.modules.os.users (name: ../../../modules/home + "/${name}");
        };
      };

    homeManager =
      {
        config,
        lib,
        ...
      }:
      {
        home = {
          username = "spector";
          homeDirectory = "/home/${config.home.username}";
          stateVersion = "23.05";
        };

        manual = {
          html.enable = false;
          json.enable = false;
          manpages.enable = true;
        };

        programs.home-manager.enable = true;
        xdg.userDirs.setSessionVariables = true;
        systemd.user.startServices = lib.mkDefault "sd-switch";
      };
  };
}
