_: {
  flake.aspects = { aspects, ... }: {
    opencode = {
      includes = [ aspects.ai-tools ];

      homeManager =
        { lib, ... }:
        let
          aiTools = import ./_ai-tools/lib.nix { inherit lib; };
        in
        {
          imports = [
            ./_opencode/permission.nix
            ./_opencode/lsp.nix
          ];

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
            skills.skills = ./_ai-tools/skills;
            context = ./_ai-tools/base.md;
          };
        };
    };
  };
}
