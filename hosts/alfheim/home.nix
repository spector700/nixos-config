{
  pkgs,
  config,
  ...
}:
let
  user = config.modules.os.mainUser;
  bambuStudioWithCert = pkgs.callPackage ../../pkgs/bambu-studio-with-bambuddy-cert.nix { };
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
        bambuStudioWithCert
        feishin
      ];

      modules = {
        theme = {
          # wallpaper = ../../modules/home/spector/theming/wallpaper2.png;
          stylix.enable = true;
        };

        programs = {
          orca-slicer.enable = true;
        };
      };
    };
  };
}
