{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.shell.claude-code;

  aiTools = import ../ai-tools { inherit lib config; };
in
{
  # imports = [
  #   ./permissions.nix
  # ];

  options.modules.shell.claude-code = {
    enable = mkEnableOption "Claude Code configuration";
  };

  config = mkIf cfg.enable {
    programs.claude-code = {
      enable = true;

      enableMcpIntegration = true;

      settings = {
        theme = "dark";

        # hooks = lib.importDir ./hooks { inherit pkgs config lib; };

        # Let default do its job
        # model = "claude-sonnet-4-5";
        verbose = true;
        includeCoAuthoredBy = false;

        statusLine = {
          type = "command";
          command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
          padding = 0;
        };

        env = {
          USE_BUILTIN_RIPGREP = "0";
        };
      };

      # inherit ((import (lib.getFile "modules/common/ai-tools") { inherit lib; }).claudeCode) agents;

      # inherit ((import (lib.getFile "modules/common/ai-tools") { inherit lib; }).claudeCode) commands;

      skillsDir = ../ai-tools/skills;

      memory.source = ../ai-tools/base.md;
    };
  };
}
