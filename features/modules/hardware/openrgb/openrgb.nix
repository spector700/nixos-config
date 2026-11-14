_: {
  flake.aspects.openrgb.nixos =
    { pkgs, ... }:
    let
      profile = "iceie";
    in
    {
      services.hardware.openrgb.enable = true;

      # When changing the profile cp -n /var/lib/OpenRGB/profiles/iceie.json features/modules/hardware/openrgb/iceie.json
      environment.etc."OpenRGB/${profile}.json".source = ./iceie.json;

      systemd.tmpfiles.rules = [
        "L /var/lib/OpenRGB/profiles/${profile}.json - - - - /etc/OpenRGB/${profile}.json"
      ];

      systemd.user.services.openrgb = {
        description = "OpenRGB";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig.ExecStart = "${pkgs.openrgb}/bin/openrgb --profile ${profile}";
        restartTriggers = [ ./iceie.json ];
      };
    };
}
