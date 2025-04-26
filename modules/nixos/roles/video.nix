{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  options.modules.roles.video = {
    enable = mkEnableOption "Enable the video role for obs and davinci-resolve";
  };
}
