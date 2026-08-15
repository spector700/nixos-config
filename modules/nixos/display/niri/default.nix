{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.modules.display.desktop.niri;
in
{
  imports = [
    inputs.niri-flake.nixosModules.niri
    { nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ]; }
  ];

  config = mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    environment.variables = {
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "niri";
    };

    systemd.user.services.niri-flake-polkit.enable = false;
  };
}
