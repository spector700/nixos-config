{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.shell.claude-code;

  aiAgents = import ../ai-tools/agents.nix { inherit lib; };
  aiCommands = import ../ai-tools/commands.nix { inherit lib; };

  statuslineScript = ''
    input=$(cat)

    RESET=$'\033[0m'
    CYAN=$'\033[1;36m'
    GREEN=$'\033[32m'
    MAGENTA=$'\033[35m'
    YELLOW=$'\033[33m'
    RED=$'\033[31m'
    DIM=$'\033[90m'

    MODEL=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.model.display_name')
    DIR=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.workspace.current_dir' | xargs basename)
    CONTEXT=$(echo "$input" | ${pkgs.jq}/bin/jq -r '.context_window.used_percentage // 0' | cut -d'.' -f1)

    if [ "$CONTEXT" -lt 50 ]; then
      CTX_COLOR=$GREEN
    elif [ "$CONTEXT" -lt 80 ]; then
      CTX_COLOR=$YELLOW
    else
      CTX_COLOR=$RED
    fi

    BRANCH=""
    if ${pkgs.git}/bin/git rev-parse --git-dir > /dev/null 2>&1; then
      BRANCH=$(${pkgs.git}/bin/git branch --show-current 2>/dev/null)
      [ -n "$BRANCH" ] && BRANCH=" $DIM|$RESET $MAGENTA$BRANCH$RESET"
    fi

    echo "$DIM[$RESET$CYAN$MODEL$RESET$DIM]$RESET $GREEN$DIR$RESET$BRANCH $DIM|$RESET $CTX_COLOR$CONTEXT%$RESET"
  '';
in
{
  imports = [
    ./hooks.nix
  ];

  options.modules.shell.claude-code = {
    enable = mkEnableOption "Claude Code configuration";
  };

  config = mkIf cfg.enable {
    programs.claude-code = {
      enable = true;

      enableMcpIntegration = true;

      settings = {
        theme = "dark";
        "env" = {
          "CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY" = "1";
          "DISABLE_TELEMETRY" = "1";
          "DISABLE_ERROR_REPORTING" = "1";
          "DISABLE_NON_ESSENTIAL_MODEL_CALLS" = "1";
          "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC" = "true";
        };

        verbose = true;
        includeCoAuthoredBy = false;

        statusLine = {
          type = "command";
          command = statuslineScript;
          # command = "input=$(cat); echo \"[$(echo \"$input\" | jq -r '.model.display_name')] 📁 $(basename \"$(echo \"$input\" | jq -r '.workspace.current_dir')\")\"";
          padding = 0;
        };

        # env = {
        #   USE_BUILTIN_RIPGREP = "0";
        # };
      };

      agents = aiAgents.toClaudeMarkdown;

      commands = aiCommands.toClaudeMarkdown;

      skillsDir = ../ai-tools/skills;

      memory.source = ../ai-tools/base.md;
    };
  };
}
