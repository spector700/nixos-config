# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Full agent guidance lives in [`AGENTS.md`](./AGENTS.md)** — read it first. This file adds Claude Code-specific context on top of it.

---

## Hosts

| Host | Arch | Role |
|------|------|------|
| `alfheim` | x86_64 | Gaming desktop (AMD CPU, NVIDIA GPU) |
| `vivo` | x86_64 | Laptop (AMD) |
| `vanaheim` | aarch64 | Homelab server (no GUI) |
| `minimal` | x86_64 | Minimal install image |

---

## Key Commands

```bash
# Format (required before committing — CI enforces this)
nix fmt

# Validate flake outputs
just check                                    # nix flake check with --impure
nix flake check                               # plain check

# Build a specific host locally
nix build .#nixosConfigurations.alfheim.config.system.build.toplevel

# Deploy to a remote host over SSH (port 5010)
just rebuild-deploy vanaheim
just rebuild-deploy alfheim

# Update flake inputs
nix flake update

# Linting (run before committing)
statix check .                                # anti-pattern detection
deadnix .                                     # unused variable/import detection
```

---

## Architecture

```
flake.nix                    # Inputs (30+) + flake-parts outputs
flake/                       # Flake-parts: fmt, pre-commit, devShell
lib/                         # Custom lib' (isx86Linux, etc.)
hosts/
  profiles.nix               # nixosSystem declarations (specialArgs: inputs, self, lib', location)
  <hostname>/default.nix     # Host-specific config + home-manager user config
modules/
  nixos/                     # Shared NixOS modules under options.modules.*
  home/spector/              # Home-manager modules (no custom options namespace)
```

**Module option namespace:** All custom NixOS options live under `modules.<category>.<name>` — never top-level NixOS namespaces.

**home-manager modules** (`modules/home/spector/`) directly configure `programs.*`, `services.*`, `home.*` — no custom options declarations needed.

**`specialArgs` always in scope:** `inputs`, `self`, `lib'` (custom lib, note apostrophe), `location` (string path to config dir).

---

## NixOS Module Pattern

```nix
{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption mkDefault mkForce mkMerge types;
  cfg = config.modules.<category>.<name>;
in
{
  options.modules.<category>.<name>.enable = mkEnableOption "...";
  config = mkIf cfg.enable { ... };
}
```

---

## Custom Claude Code Agent

A `nixos-config-writer` agent is configured in `.claude/agents/`. Use the Task tool with `subagent_type: "nixos-config-writer"` when writing, editing, or refactoring NixOS configuration files — it has specialized knowledge of this repo's patterns.

---

## Secrets

Secrets use sops-nix + the private `nix-secrets` flake input. Never commit `.age` files or private keys (pre-commit blocks this). Reference secrets via `config.sops.secrets."path/to/key".path`.

---

## CI

Two GitHub Actions workflows on push/PR:
1. **flake-check.yml** — `nix flake check`
2. **fmt.yml** — treefmt formatting check

Always run `nix fmt` and `just check` before committing.
