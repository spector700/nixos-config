{
  config,
  pkgs,
  lib,
  inputs',
  ...
}: let
  reload_script = pkgs.writeShellScript "reload_eww" ''
    windows=$(eww windows | rg '\*' | tr -d '*')

    systemctl --user restart eww.service

    echo $windows | while read -r w; do
      eww open $w
    done
  '';

in {
    programs.eww = {
      enable = true;
      package = pkgs.eww-wayland;
     # remove nix files
    configDir = lib.cleanSourceWith {
        filter = name: _type: let
          baseName = baseNameOf (toString name);
        in
          !(lib.hasSuffix ".nix" baseName) && (baseName != "_colors.scss");
        src = lib.cleanSource ./.;

      };
    };

    home.packages = with pkgs; [
      jc
      jaq
      socat
      material-symbols
    ];

    systemd.user.services.eww = {
      Unit = {
        Description = "Eww Daemon";
        # not yet implemented
        # PartOf = ["tray.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.eww-wayland}/bin/eww daemon --no-daemonize";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
}
