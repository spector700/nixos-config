{ pkgs, ... }:
{
  programs.claude-code.settings.hooks = {

    # Auto-format .nix files after any edit/write
    PostToolUse = [
      {
        matcher = "Edit|MultiEdit|Write";
        hooks = [
          {
            type = "command";
            command = ''
              FILE=$(${pkgs.jq}/bin/jq -r '.tool_input.file_path // .tool_input.new_file // empty')
              if [[ "$FILE" == *.nix ]] && [ -f "$FILE" ]; then
                nix fmt "$FILE" 2>/dev/null || true
              fi
            '';
          }
        ];
      }
    ];

    # Block dangerous bash patterns before execution
    PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = ''
              CMD=$(${pkgs.jq}/bin/jq -r '.tool_input.command // empty')
              if echo "$CMD" | grep -qE 'rm[[:space:]]+-rf[[:space:]]+[~\/\*]|rm[[:space:]]+-rf[[:space:]]+-'; then
                echo "Blocked: destructive rm pattern" >&2
                exit 2
              fi
              if echo "$CMD" | grep -qE '(curl|wget)[[:space:]].*\|[[:space:]]*(bash|sh|zsh)'; then
                echo "Blocked: pipe-to-shell pattern" >&2
                exit 2
              fi
            '';
          }
        ];
      }
    ];

  };
}
