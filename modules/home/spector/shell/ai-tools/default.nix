{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) getExe mkDefault;
  aiCommands = import ./commands.nix { inherit lib; };
  aiAgents = import ./agents.nix { inherit lib; };

in
{
  claudeCode = {
    commands = aiCommands.toClaudeMarkdown;
    agents = aiAgents.toClaudeMarkdown;
  };

  opencode = {
    commands = aiCommands.toOpenCodeMarkdown;
    inherit (aiAgents) agents;
    renderAgents = aiAgents.toOpenCodeMarkdown;
  };

  home.packages = with pkgs; [
    agent-browser
  ];

  programs.mcp = {
    # MCP documentation
    # See: https://modelcontextprotocol.io/
    enable = true;
    servers = {
      filesystem = {
        # command = getExe mcpPkgs.mcp-server-filesystem;
        args = mkDefault [
          config.home.homeDirectory
          "${config.home.homeDirectory}/Documents"
        ];
      };

      nixos = {
        # command = getExe pkgs.mcp-nixos;
      };
    };
  };

  mergeCommands = existingCommands: newCommands: existingCommands // newCommands;
}
