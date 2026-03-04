{ lib, ... }:

let
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

  mergeCommands = existingCommands: newCommands: existingCommands // newCommands;
}
