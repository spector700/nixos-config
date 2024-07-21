{
  pkgs,
  lib,
  config,
  ...
}:
let
  suspendScriptLaptop = pkgs.writeShellScript "suspend-script" ''
    ${pkgs.pipewire}/bin/pw-cli i all 2>&1 | ${pkgs.ripgrep}/bin/rg running -q
    # only suspend if audio isn't running
    if [ $? == 1 ]; then
      ${pkgs.systemd}/bin/systemctl suspend
    fi
  '';

  suspendScriptDesktop = pkgs.writeShellScript "suspend-script" ''
    ${pkgs.pipewire}/bin/pw-cli i all 2>&1 | ${pkgs.ripgrep}/bin/rg running -q
    # only suspend if audio isn't running
    if [ $? == 1 ]; then
      ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
      fi
  '';
in
{
  # screen idle
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
        lock_cmd = lib.getExe config.programs.hyprlock.package;

        listener = [
          {
            timeout = 5;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
