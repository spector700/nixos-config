{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.shell.opencode;
  aiTools = import ../ai-tools/lib.nix { inherit lib; };
in
{
  imports = [
    ./permission.nix
    ./lsp.nix
    # ./oh-my-opencode.nix
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
        autoupdate = true;

        plugin = [
          # Dynamic context pruning
          "@tarquinen/opencode-dcp@latest"
          # Support background shell commands
          "opencode-pty"
          "@plannotator/opencode@latest"

          "oh-my-openagent@latest"
          "@simonwjackson/opencode-direnv@latest"
        ];
      };

      inherit (aiTools.opencode) commands;
      agents = aiTools.opencode.renderAgents;

      skills = {
        skills = ../ai-tools/skills;
      };

      context = ../ai-tools/base.md;
    };
  };
}
