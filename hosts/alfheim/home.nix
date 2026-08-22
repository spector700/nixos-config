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
  home-manager.users.${user}.config = {
    sops.secrets = {
      "keys/ssh/${user}_${config.networking.hostName}" = {
        path = "/home/${user}/.ssh/id_spector";
      };
    };

    home.packages = [
      pkgs.gimp
      bambuStudioWithCert
      pkgs.feishin
    ];

    modules = {
      theme = {
        wallpaper = ../../modules/home/spector/theming/wallpaper2.png;
        stylix.enable = false;
      };

      desktop.bar = "noctalia";

      services.nextcloud-client.enable = true;

      shell = {
        opencode.enable = true;
        claude-code.enable = true;
      };

      programs = {
        nixcord.enable = true;
        zathura.enable = true;
        orca-slicer.enable = true;
        rofi.enable = false;
        brave.enable = true;
        zen.enable = true;
      };
    };
  };
}
