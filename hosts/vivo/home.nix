{
  pkgs,
  config,
  ...
}:
let
  user = config.modules.os.mainUser;
in
{
  home-manager.users.${user}.config = {
    home.packages = with pkgs; [
      moonlight-qt
      parsec-bin
    ];

    modules = {
      desktop.bar = "dankMaterialShell";

      theme = {
        wallpaper = ../../modules/home/spector/theming/wallpaper2.png;
        stylix.enable = false;
      };

      services.nextcloud-client.enable = true;

      programs = {
        spicetify.enable = true;
        nixcord.enable = true;
        zathura.enable = true;
        rofi.enable = true;
        zen.enable = true;
      };
    };
  };
}
