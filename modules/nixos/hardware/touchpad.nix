{ lib, config, ... }:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.modules.roles.laptop.enable {
    services.libinput = {
      enable = true;

      # disable mouse acceleration
      mouse = {
        accelProfile = "flat";
        accelSpeed = "0";
        middleEmulation = false;
      };

      touchpad = {
        naturalScrolling = true;
        tapping = true;
        clickMethod = "clickfinger";
        disableWhileTyping = true;
      };
    };
  };
}
