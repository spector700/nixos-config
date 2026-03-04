{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.shell.opencode;

  aiTools = import ../ai-tools { inherit lib; };

  # For each subdirectory in skills/, read its SKILL.md
  importSkills =
    dir:
    let
      entries = builtins.readDir dir;
      subdirs = lib.filterAttrs (_name: type: type == "directory") entries;
    in
    lib.mapAttrs (
      name: _:
      let
        skillFile = dir + "/${name}/SKILL.md";
      in
      builtins.readFile skillFile
    ) subdirs;
in
{
  imports = [
    ./permission.nix
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

        plugin = [
          # Support google account auth
          "opencode-gemini-auth@latest"
          # Dynamic context pruning
          "@tarquinen/opencode-dcp@latest"
          # Support background shell commands
          "opencode-pty"

          "oh-my-opencode"
        ];
      };

      inherit (aiTools.opencode) commands;
      agents = aiTools.opencode.renderAgents;

      skills = importSkills ../ai-tools/skills;

      rules = builtins.readFile ../ai-tools/base.md;
    };
  };
}
