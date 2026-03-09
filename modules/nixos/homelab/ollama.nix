{
  config,
  pkgs,
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
        enable = false;
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
        package = pkgs.ollama-cuda;
        host = "0.0.0.0";
        # Synchronize all currently installed models with those declared in loadModels, removing any models that are installed but not currently declared there.
        syncModels = true;
        loadModels = [
          "qwen3.5:latest"
        ];
        port = 11434;

        environmentVariables = {
          OLLAMA_NUM_PARALLEL = "32";
          OLLAMA_MAX_LOADED_MODELS = "8";
          OLLAMA_MAX_QUEUE = "1024";

          OLLAMA_FLASH_ATTENTION = "true";
          OLLAMA_KV_CACHE_TYPE = "q8_0";
          OLLAMA_CONTEXT_LENGTH = "64000";
        };
      };
    };

    environment.persistence."/persist".directories = mkIf config.modules.boot.impermanence.enable [
      {
        directory = "/var/lib/private";
        mode = "0700";
      }
    ];
  };
}
