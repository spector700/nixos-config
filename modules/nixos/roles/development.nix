{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.modules.roles.development = {
    enable = mkEnableOption "Enable the development role";
  };
}
