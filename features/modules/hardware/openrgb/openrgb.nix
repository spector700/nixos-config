_: {
  flake.aspects.openrgb.nixos =
    { pkgs, ... }:
    let
      profile = "iceie.orp";
    in
    {
      services.hardware.openrgb.enable = true;

      environment.etc."OpenRGB/${profile}".source = ./${profile};

      systemd.user.services.openrgb = {
        description = "OpenRGB";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig.ExecStart = "${pkgs.openrgb}/bin/openrgb --profile /etc/OpenRGB/${profile}";
        restartTriggers = [ "/etc/OpenRGB/${profile}" ];
      };
    };
}
