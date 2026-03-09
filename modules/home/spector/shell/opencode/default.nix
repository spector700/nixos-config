{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.shell.opencode;

  aiTools = import ../ai-tools { inherit pkgs lib config; };

  superpowers = rec {
    src = inputs.superpowers;
    skills = "${src}/skills";
    opencode-plugin = "${src}/.opencode/plugins/superpowers.js";
  };
in
{
  imports = [
    ./permission.nix
    ./lsp.nix
    ./oh-my-opencode.nix
  ];

  options.modules.shell.opencode = {
    enable = mkEnableOption "OpenCode configuration";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;

      enableMcpIntegration = true;

      settings = {
        autoshare = false;
        autoupdate = false;

        provider = {
          ollama = {
            npm = "@ai-sdk/openai-compatible";
            name = "Ollama";
            options = {
              baseURL = "http://localhost:11434/v1";
            };
            models = {
              "qwen3.5:latest" = {
                name = "Qwen 3.5";
                # limit = {
                #   context = 61440;
                #   output = 24576;
                # };
              };
            };
          };
        };

        plugin = [
          # Dynamic context pruning
          "@tarquinen/opencode-dcp@latest"
          # Support background shell commands
          "opencode-pty"

          "oh-my-opencode@latest"
          "@simonwjackson/opencode-direnv@latest"
        ];

        mcp = {
          nixos = {
            type = "local";
            command = [
              "nix"
              "run"
              "github:utensils/mcp-nixos"
              "--"
            ];
            enabled = true;
          };
          gh_grep = {
            type = "remote";
            url = "https://mcp.grep.app/";
            enabled = true;
            timeout = 10000;
          };
          deepwiki = {
            type = "remote";
            url = "https://mcp.deepwiki.com/mcp";
            enabled = true;
            timeout = 10000;
          };
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
            enabled = true;
            timeout = 10000;
          };
        };
      };

      inherit (aiTools.opencode) commands;
      agents = aiTools.opencode.renderAgents;

      skills = {
        skills = ../ai-tools/skills;
        superpowers = superpowers.skills;
      };

      rules = builtins.readFile ../ai-tools/base.md;
    };
  };
}
