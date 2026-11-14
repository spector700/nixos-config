{
  pkgs,
  config,
  ...
}:
let
  user = config.modules.os.mainUser;
in
{
  home-manager.users.${user} = {

    config = {
      sops.secrets = {
        "keys/ssh/${user}_${config.networking.hostName}" = {
          path = "/home/${user}/.ssh/id_spector";
        };
      };

      home.packages = with pkgs; [
        gimp
        feishin
      ];

      modules = {
        theme = {
          stylix.enable = true;
        };
      };
    };
  };
}
