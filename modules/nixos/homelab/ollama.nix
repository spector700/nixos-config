{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.homelab.ollama;
in
{
  options.modules.homelab.ollama = {
    enable = mkEnableOption "Enable ollama";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
      port = 11434;
    };
  };
}
