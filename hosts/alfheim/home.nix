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
    sops.secrets = {
      "keys/ssh/${user}_${config.networking.hostName}" = {
        path = "/home/${user}/.ssh/id_spector";
      };
    };

    home.packages = with pkgs; [
      gimp
      (pkgs.bambu-studio.override {
        withNvidiaGLWorkaround = true;
      })
      feishin
    ];

    modules = {
      theme = {
        wallpaper = ../../modules/home/spector/theming/wallpaper2.png;
        stylix.enable = true;
      };

      desktop.bar = "dankMaterialShell";

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
