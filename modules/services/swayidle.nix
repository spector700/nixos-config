{ pkgs, host, lib, ... }:

let
  suspendScript = pkgs.writeShellScript "suspend-script" ''
    ${pkgs.pipewire}/bin/pw-cli i all | ${pkgs.ripgrep}/bin/rg running
    # only suspend if audio isn't running
    if [ $? == 1 ]; then
      ${pkgs.systemd}/bin/systemctl suspend
    fi
  '';
in
{

  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];

  services.swayidle = with host; if hostName == "laptop" then {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { event = "lock"; command = "lock"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f"; }
    ];
    systemdTarget = "xdg-desktop-portal-hyprland.service";
  } else {
    enable = true;
    timeouts = [
      { timeout = 400; command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off"; }
    ];
  };
}
