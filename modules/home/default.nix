{
  inputs,
  self,
  config,
  lib,
  location,
  ...
}:
let
  inherit (lib) genAttrs;
in
{
  nixpkgs.overlays = [ inputs.hyprpanel.overlay ];

  home-manager = {
    # tell home-manager to be as verbose as possible
    verbose = true;

    backupFileExtension = "backup";

    # use the system configuration’s pkgs argument
    # this ensures parity between nixos' pkgs and hm's pkgs
    useGlobalPkgs = true;

    # enable the usage user packages through
    # the users.users.<name>.packages option
    useUserPackages = true;

    # extra specialArgs passed to Home Manager
    # for reference, the config argument in nixos can be accessed
    # in home-manager through osConfig without us passing it
    # extraSpecialArgs = lib.nixosSystem.specialArgs;
    extraSpecialArgs = {
      inherit inputs self location;
    };

    # per-user Home Manager configuration
    # the genAttrs function generates an attribute set of users
    # as `user = ./user` where user is picked from a list of
    # users in modules.os.users
    # the system expects user directories to be found in the present
    # directory, or will exit with directory not found errors
    users = genAttrs config.modules.os.users (name: ./${name});
  };
}
