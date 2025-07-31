{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types optionals;
  user = config.modules.os.mainUser;
  subPath = "passwords/${user}";
in
{
  config = {
    users = {
      # allow password to be set by sops-nix
      mutableUsers = false;

      users.${user} = {
        # System User
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "dialout" # for USB Serial
        ]
        ++ optionals config.networking.networkmanager.enable [ "networkmanager" ];
        hashedPasswordFile = config.sops.secrets.${subPath}.path;
        # hashedPassword = "$y$j9T$0LAzDTG8mgvgvOuu46PbF1$zWgPWtHOfvXhI8jJBI8UG6Pcl5o4I/k0J4hZbftjHu2";
        shell = pkgs.zsh; # Default shell
      };
    };

    # users.users.root = {
    #   shell = pkgs.zsh;
    #   inherit (config.users.users.${user}) hashedPasswordFile;
    #   inherit (config.users.users.${user}) hashedPassword; # This comes from hosts/common/optional/minimal.nix and gets overridden if sops is working
    # initialPassword = "nixos";
    # openssh.authorizedKeys.keys = config.users.users.${user}.openssh.authorizedKeys.keys; # root's ssh keys are mainly used for remote deployment.
    # };
  };

  config.warnings = optionals (config.modules.os.users == [ ]) [
    ''
      You have not added any users to be supported by your system. You may end up with an unbootable system!

      Consider setting {option}`config.modules.system.users` in your configuration
    ''
  ];

  options.modules.os = {
    mainUser = mkOption {
      type = types.enum config.modules.os.users;
      default = builtins.elemAt config.modules.os.users 0;
      description = ''
        The username of the main user for your system.

        In case of a multiple systems, this will be the user with priority in ordered lists and enabled options.
      '';
    };

    users = mkOption {
      type = with types; listOf str;
      default = [ "spector" ];
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
