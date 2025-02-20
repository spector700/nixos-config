{
  osConfig,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  cfg = osConfig.modules.roles.development;
in
{
  config = mkIf cfg.enable {
    # modules.shell.zellij.enable = mkDefault true;
  };
}
