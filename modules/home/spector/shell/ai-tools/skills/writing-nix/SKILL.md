---
name: writing-nix
description: Write idiomatic, maintainable, and performant Nix code. Use when creating or refactoring Nix expressions, modules, overlays, packages, flake outputs, and helper functions, including anti-pattern avoidance and evaluation/build performance practices. Triggers on: writing NixOS modules, home-manager config, mkIf/mkMerge usage, option type design, flake.nix edits.
---

# Writing Nix

## Core Principles

1. **Declarative over Imperative**: Describe _what_, not _how_.
2. **Explicit over Implicit**: Avoid magic scoping or hidden dependencies.
3. **Hermetic**: No side effects, no network access during build (except
   fixed-output derivations).

## Critical Anti-Patterns

### 1. The `with` Statement

**NEVER use `with`**. It breaks static analysis, tools (LSP), and readability.
For a single symbol use direct qualification; for 3+ symbols use `inherit`.

```nix
# BAD
meta = with lib; { license = licenses.mit; };

# GOOD — single symbol
meta = { license = lib.licenses.mit; };

# GOOD — multiple symbols (inherit form, nixfmt style)
let
  inherit (lib)
    mkIf
    mkEnableOption
    types
    ;
in ...
```

### 2. Recursive Attributes (`rec`)

Avoid `rec` when `let-in` suffices. `rec` can cause infinite recursion and
expensive evaluation.

```nix
# BAD
rec {
  version = "1.0";
  name = "pkg-${version}";
}

# GOOD
let
  version = "1.0";
in {
  inherit version;
  name = "pkg-${version}";
}
```

### 3. Over-wide option surfaces

Do not expose options for hypothetical use cases. Keep interfaces minimal and
intentional.

## Module Design — NixOS

Every NixOS module in this repo follows this exact structure. Custom options
live under `modules.<category>.<name>` — never a top-level NixOS namespace.

```nix
{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    mkDefault
    mkForce
    mkMerge
    types
    ;
  cfg = config.modules.<category>.<name>;
in
{
  options.modules.<category>.<name> = {
    enable = mkEnableOption "description of what this enables";
  };

  config = mkIf cfg.enable {
    # implementation
  };
}
```

Key conventions:
- **`cfg` alias** — always bind `config.modules.<category>.<name>` to `cfg`.
- **`mkDefault`** — marks a value as overridable (priority 1000). Use for
  sensible defaults that host configs may override.
- **`mkForce`** — overrides all other definitions (priority 50). Use sparingly,
  only at the host level when you must win a priority conflict.
- **`mkIf` + `mkMerge`** — use bare `mkIf cfg.enable { ... }` for simple
  modules. Reach for `mkIf cfg.enable (mkMerge [ { ... } { ... } ])` only when
  a module has several logically independent conditional blocks that benefit from
  separation (e.g., networking config vs. firewall vs. systemd units).
- **Multi-line inherit** — nixfmt enforces the trailing `;` on its own line for
  3+ symbols (see anti-pattern §1 above). Always write it this way.

## Module Design — home-manager

Home-manager modules live under `modules/home/spector/` and come in two forms:

### With options (optional features)

Same `modules.*` namespace and `mkIf cfg.enable` guard as NixOS modules, but
the `config` block configures `programs.*`, `services.*`, `home.*` etc. Can
also receive `osConfig` to cross-reference the NixOS system config.

```nix
{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.desktop.hyprpaper;
in
{
  options.modules.desktop.hyprpaper = {
    enable = mkEnableOption "hyprpaper wallpaper daemon";
  };

  config = mkIf cfg.enable {
    services.hyprpaper.enable = true;
    # osConfig.modules.display.monitors is available here
  };
}
```

### Direct configuration (always-enabled config)

Simpler modules with no option guard — they configure programs directly and are
always active when imported:

```nix
{ config, ... }:
{
  programs.git = {
    enable = true;
    userName = "spector700";
  };
}
```

`specialArgs` always in scope: `inputs`, `self`, `lib'` (custom lib — note the
apostrophe, distinct from standard `lib`), `location` (string path to config dir).

## Common Patterns

### `lib.optionals` / `lib.optional`

Prefer over verbose `if/else []`:

```nix
# BAD
packages = if enableFoo then [ pkgs.foo ] else [];

# GOOD
packages = lib.optionals enableFoo [ pkgs.foo ];
# singular form for a single item:
packages = lib.optional enableBar pkgs.bar;
```

### Impermanence

Modules that manage stateful services should conditionally persist their data:

```nix
environment.persistence."/persist".directories =
  mkIf config.modules.boot.impermanence.enable [
    {
      directory = "/var/lib/myservice";
      user = "myservice";
      group = "myservice";
      mode = "0700";
    }
  ];
```

### sops-nix Secrets

Secrets come from the private `nix-secrets` flake input. Never commit `.age`
files or private keys.

NixOS reference:
```nix
users.users.spector.hashedPasswordFile =
  config.sops.secrets."users/spector/password".path;
```

Home-manager reference:
```nix
sops.secrets."keys/ssh/spector_alfheim" = {
  path = "/home/spector/.ssh/id_spector";
};
```

## Overlay Pattern

Use `final` for self-references (the overridden package set), `prev` for
upstream:

```nix
final: prev: {
  myPkg = prev.myPkg.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./fix.patch ];
  });
  # use final.someOtherPkg if you need the already-overridden version of it
}
```

## flake-parts `perSystem`

This repo uses flake-parts. The `perSystem` module pattern:

```nix
{ inputs, ... }:
{
  perSystem = { pkgs, config, ... }: {
    packages.default = pkgs.hello;
    devShells.default = pkgs.mkShell {
      packages = [ pkgs.git ];
    };
  };
}
```

## Debugging

Eval errors are frequent. Two high-value tools:

**`nix repl`**
```
nix repl
:load .          # load the flake
:b drv           # build a derivation bound to `drv`
```

**`builtins.trace`** — prints during evaluation, returns the second argument:
```nix
builtins.trace "value: ${builtins.toJSON someAttr}" someAttr
```

## Expression Style

- Prefer attrset lookup over long if/else chains for multi-branch selection.
- Keep temporary variables close to usage.
- Keep functions small and names descriptive.

## Performance Practices

Evaluation:
- Avoid forcing large attrsets when not needed.
- Avoid expensive repeated imports and computations.

Build:
- Minimize runtime closures.
- Keep sources clean (`cleanSource`/filters) to avoid rebuild churn.

## Validation

After edits, run in order:

```bash
nix fmt           # format (required before committing — CI enforces this)
deadnix .         # find unused variables/imports
nix flake check   # validate all flake outputs
```

## Output Contract

Report:

```text
CHANGES MADE:
- <file>: <what changed and why>

THINGS I DIDN'T TOUCH:
- <file>: <why intentionally unchanged>

POTENTIAL CONCERNS:
- <risk or follow-up checks>
```
