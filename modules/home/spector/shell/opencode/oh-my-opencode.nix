{
  xdg.configFile."opencode/oh-my-opencode.json".text = builtins.toJSON {
    "$schema" =
      "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
    runtime_fallback.enabled = true;

    agents = {
      sisyphus.model = "ollama/qwen3.5:latest";
      metis.model = "ollama/qwen3.5:latest";
      prometheus.model = "ollama/qwen3.5:latest";
      atlas.model = "ollama/qwen3.5:latest";
      hephaestus.model = "ollama/qwen3.5:latest";
      oracle.model = "ollama/qwen3.5:latest";
      momus.model = "ollama/qwen3.5:latest";
      multimodal-looker.model = "ollama/qwen3.5:latest";
      librarian.model = "ollama/qwen3.5:latest";
      explore.model = "ollama/qwen3.5:latest";
    };

    categories = {
      visual-engineering.model = "ollama/qwen3.5:latest";
      ultrabrain.model = "ollama/qwen3.5:latest";
      deep.model = "ollama/qwen3.5:latest";
      artistry.model = "ollama/qwen3.5:latest";
      quick.model = "ollama/qwen3.5:latest";
      # "unspecified-high".model = "ollama/qwen3.5:latest";
      # "unspecified-low".model = "ollama/qwen3.5:latest";
      writing.model = "ollama/qwen3.5:latest";
    };
  };
}
