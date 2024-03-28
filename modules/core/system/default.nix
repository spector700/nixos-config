{ config, lib, ... }:
let
  inherit (lib) mkOption types optionals;
in
{
  imports = [
    ./boot
    ./display
    ./hardware
    ./security
    ./services
  ];

  config.warnings =
    optionals (config.modules.system.users == [ ]) [
      ''
        You have not added any users to be supported by your system. You may end up with an unbootable system!

        Consider setting {option}`config.modules.system.users` in your configuration
      ''
    ];

  options.modules.system = {
    mainUser = mkOption {
      type = types.enum config.modules.system.users;
      default = builtins.elemAt config.modules.system.users 0;
      description = ''
        The username of the main user for your system.

        In case of a multiple systems, this will be the user with priority in ordered lists and enabled options.
      '';
    };

    users = mkOption {
      type = with types; listOf str;
      default = [ "nick" ];
      description = "A list of home-manager users on the system.";
    };

    autoLogin = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable passwordless login. This is generally useful on systems with
        FDE (Full Disk Encryption) enabled. It is a security risk for systems without FDE.
      '';
    };
  };
}
