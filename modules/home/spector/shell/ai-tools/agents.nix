{ lib, ... }:
let
  inherit (lib) mapAttrs;

  agentsBasePath = ./agents;

  agents = {
    # sensei = {
    #   mode = "primary";
    #   description = "Sensei Agent";
    #   prompt = ''
    #     # Sensei Agent
    #
    #     You are a professional software engineer who'll mentor the user.
    #
    #     ## Guidelines
    #     - Do not spoon-feed the solution to the user. Provide the user with hints, suggestions,
    #       and guidance instead of offering and implementing direct solutions.
    #     - Direct the user to relevant blogs, documentation, and resources whenever applicable.
    #   '';
    #   model = {
    #     claude = "sonnet";
    #     opencode = "ollama/qwen3-8b";
    #   };
    #   tools = [
    #     "Read"
    #     "Edit"
    #     "Write"
    #     "Grep"
    #     "Glob"
    #     "Bash"
    #   ];
    #   permission = {
    #     edit = "ask";
    #     bash = "ask";
    #   };
    # };

    debugger = {
      name = "debugger";
      description = "Debugging specialist for errors, exceptions, test failures, and unexpected behavior. Use when encountering issues that need systematic root cause analysis.";
      tools = [
        "Read"
        "Edit"
        "Bash"
        "Grep"
        "Glob"
      ];
      model = {
        claude = "sonnet";
        opencode = "github-copilot/gpt-5.2";
      };
      permission = {
        edit = "ask";
        bash = "ask";
      };
      content = builtins.readFile (agentsBasePath + "/debugger.md");
    };

    code-reviewer = {
      name = "code-reviewer";
      description = "Code quality guardian performing thorough reviews for correctness, security, maintainability, and best practices. Use before merging or after significant changes.";
      tools = [
        "Read"
        "Grep"
        "Glob"
        "Bash"
      ];
      model = {
        claude = "sonnet";
        opencode = "github-copilot/gpt-5.2";
      };
      permission = {
        bash = "ask";
      };
      content = builtins.readFile (agentsBasePath + "/code-reviewer.md");
    };

    security-auditor = {
      name = "security-auditor";
      description = "Security specialist for vulnerability assessment, configuration hardening, and secrets hygiene. Use for NixOS service configs, application security reviews, and infrastructure audits.";
      tools = [
        "Read"
        "Grep"
        "Glob"
      ];
      model = {
        claude = "sonnet";
        opencode = "github-copilot/gpt-5.2";
      };
      permission = { };
      content = builtins.readFile (agentsBasePath + "/security-auditor.md");
    };

    test-runner = {
      name = "test-runner";
      description = "Test execution specialist. Use after code changes to run tests, analyze failures, and suggest fixes. Keeps verbose test output out of the main conversation.";
      tools = [
        "Read"
        "Bash"
        "Grep"
        "Glob"
        "Edit"
      ];
      model = {
        claude = "haiku";
        opencode = "github-copilot/gpt-5-mini";
      };
      permission = {
        edit = "ask";
        bash = "ask";
      };
      content = builtins.readFile (agentsBasePath + "/test-runner.md");
    };

    refactorer = {
      name = "refactorer";
      description = "Code refactoring specialist for improving code structure, readability, and maintainability without changing behavior. Use for focused refactoring tasks in isolated context.";
      tools = [
        "Read"
        "Edit"
        "Write"
        "Grep"
        "Glob"
        "Bash"
      ];
      model = {
        claude = "sonnet";
        opencode = "github-copilot/gpt-5.2";
      };
      permission = {
        edit = "ask";
        bash = "ask";
      };
      content = builtins.readFile (agentsBasePath + "/refactorer.md");
    };

    researcher = {
      name = "researcher";
      description = "Deep research specialist for technology decisions, tool comparisons, and learning new topics. Use when you need current, synthesized information from multiple web sources. Trigger for 'research X', 'compare A vs B', 'what's the best way to do Y', 'is X still maintained'.";
      tools = [
        "WebSearch"
        "WebFetch"
        "Read"
        "Write"
        "Bash"
      ];
      model = {
        claude = "sonnet";
        opencode = "github-copilot/gpt-5.2";
      };
      permission = {
        bash = "ask";
        webfetch = "allow";
      };
      content = builtins.readFile (agentsBasePath + "/researcher.md");
    };

  };

  # Claude Code expects YAML frontmatter with: name, description, tools (comma-sep), model
  renderClaudeFrontmatter = agent: ''
    ---
    name: ${agent.name}
    description: ${agent.description}
    tools: ${lib.concatStringsSep ", " agent.tools}
    model: ${agent.model.claude or agent.model}
    ---
  '';

  renderClaudeAgent = agent: ''
    ${lib.trim (renderClaudeFrontmatter agent)}

    ${lib.trim agent.content}
  '';

  # OpenCode expects YAML frontmatter with: description, mode, model, tools
  renderOpenCodeTools =
    agent:
    let
      allowed = map lib.toLower agent.tools;
      isAllowed = t: lib.elem t allowed;
      coreTools = [
        "bash"
        "edit"
        "webfetch"
        "write"
      ];
      coreToolLines = map (t: "  ${t}: ${if isAllowed t then "true" else "false"}") coreTools;
    in
    lib.concatStringsSep "\n" coreToolLines;

  renderOpenCodeFrontmatter = agent: ''
    ---
    description: ${agent.description}
    mode: all
    model: ${agent.model.opencode or agent.model}

    tools:
    ${renderOpenCodeTools agent}
    ---
  '';

  renderOpenCodeAgent = agent: ''
    ${lib.trim (renderOpenCodeFrontmatter agent)}

    ${lib.trim agent.content}
  '';

  toClaudeMarkdown = mapAttrs (_name: renderClaudeAgent) agents;
  toOpenCodeMarkdown = mapAttrs (_name: renderOpenCodeAgent) agents;
in
{
  inherit agents toClaudeMarkdown toOpenCodeMarkdown;
}
