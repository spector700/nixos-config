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
    services = {
      open-webui = {
        enable = true;
        environment = {
          ANONYMIZED_TELEMETRY = "False";
          DO_NOT_TRACK = "True";
          SCARF_NO_ANALYTICS = "True";

          # Only available inside VPN
          # WEBUI_AUTH = "False";

          # Web Search
          ENABLE_RAG_WEB_SEARCH = "True";
          # SEARXNG_QUERY_URL = "https://searx.vaz.ovh/search?q=<query>";
          # RAG_WEB_SEARCH_ENGINE = "searxng";
          ENABLE_AUTOCOMPLETE_GENERATION = "True";
          ENABLE_OLLAMA_API = if config.services.ollama.enable then "True" else "False";
        };
      };

      ollama = {
        enable = true;
        acceleration = "cuda";
        host = "0.0.0.0";
        loadModels = [
          "gemma3:12b"
          "deepseek-r1:latest"
        ];
        port = 11434;
        # openFirewall = true;
      };
    };

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      {
        directory = "/var/lib/private/open-webui";
        mode = "0700";
      }
      {
        directory = "/var/lib/private/ollama";
        mode = "0700";
      }
    ];
  };
}
