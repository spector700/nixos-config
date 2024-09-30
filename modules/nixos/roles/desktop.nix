{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.modules.roles.desktop = {
    enable = mkEnableOption "Enable the Desktop role";
  };
}
