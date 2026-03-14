# AGENTS.md — NixOS Configuration

Guidance for agentic coding agents operating in this repository.

---

## Repository Overview

NixOS flake configuration for 4 hosts:
- **alfheim** — Gaming desktop (x86_64, AMD CPU, NVIDIA GPU)
- **vivo** — Laptop (x86_64, AMD)
- **vanaheim** — Homelab server (aarch64)
- **minimal** — Minimal base config

Stack: flake-parts, NixOS unstable, home-manager, disko, sops-nix, stylix, Hyprland WM, impermanence.

Notable additional flake inputs: `chaotic` (CachyOS kernel), `noctalia` (noctalia-shell bar), `superpowers` (opencode skills plugin), `dev-assistant` (nix project scaffolding), `gaming` (nix-gaming tweaks), `xivlauncher-rb`, `nix-citizen`.

---

## Build & Lint Commands

### Format (required before committing)
```bash
nix fmt                         # Format all .nix and shell files via treefmt
```

### Lint
```bash
nix flake check                 # Validate all flake outputs (CI runs this)
deadnix .                       # Find unused variables/imports (statix runs via treefmt/nix fmt)
```

### Build a host
```bash
nix build .#nixosConfigurations.alfheim.config.system.build.toplevel
nix build .#nixosConfigurations.vivo.config.system.build.toplevel
```

### Check formatting (CI equivalent)
```bash
nix build .#checks.x86_64-linux.treefmt    # Formatting check
nix build .#checks.x86_64-linux.pre-commit # Pre-commit hook checks
```

### Apply config (on target host)
```bash
sudo nixos-rebuild switch --flake .#alfheim
sudo nixos-rebuild switch --flake .#vivo
```

### Deploy to a remote host
```bash
just rebuild-deploy vanaheim   # SSH into host (port 5010) and switch
just rebuild-deploy alfheim
```
Remote hosts expose SSH on **port 5010** (not 22). The `rebuild-deploy` recipe runs
`nixos-rebuild --target-host HOST --sudo --impure --flake .#HOST switch` via `NIX_SSHOPTS="-p5010"`.

### Pre-commit hooks (auto-runs on commit)
Hooks: `actionlint`, `luacheck`, `detect-private-keys`, `trim-trailing-whitespace`,
`check-case-conflicts`, `check-symlinks`, `end-of-file-fixer`, `treefmt`.

Excludes: `flake.lock`, `*.age`, `*.sh` files.

---

## Directory Structure

```
flake.nix                    # Entry point, defines inputs + flake-parts
flake/                       # Flake-parts modules (fmt, pre-commit, shell)
lib/                         # Custom lib' functions (isx86Linux, etc.)
pkgs/                        # Custom package overlays
hosts/
  profiles.nix               # nixosSystem declarations with specialArgs
  alfheim/                   # Host-specific config + hardware-configuration.nix
  vivo/
  vanaheim/
  minimal/
modules/
  nixos/                     # Shared NixOS modules (boot, hardware, services, roles…)
  home/spector/              # Home-manager config (shell, desktop, programs, theming…)
```

---

## Architecture Notes

**Module option namespace:** All custom NixOS options live under `modules.<category>.<name>` — never top-level NixOS namespaces.

**home-manager modules** (`modules/home/spector/`) directly configure `programs.*`, `services.*`, `home.*` — no custom options declarations needed.

**`specialArgs` always in scope:** `inputs`, `self`, `lib'` (custom lib, note apostrophe), `location` (string path to config dir).

---

> **Code Style / Patterns** — see `modules/home/spector/shell/ai-tools/skills/writing-nix/SKILL.md`

---

## Common Pitfalls

- **Do not** use `nix-env` or imperative commands — everything is declarative
- **Do not** add options outside the `modules.*` namespace for custom options (exception: `homelab.*` infrastructure options — see Architecture Notes above)
- **Do not** commit `*.age` secret files or private keys — pre-commit will catch this
- **Do not** skip `nix fmt` — the CI fmt check will fail
- `lib'` (with apostrophe) is the **custom lib**, not the standard `lib` — keep them distinct
- `flake.lock` is excluded from formatting and pre-commit hooks
- Shell scripts (`*.sh`) are excluded from pre-commit hooks but still formatted by shfmt

---

## CI / GitHub Actions

Two workflows run on push/PR:
1. **flake-check.yml** — runs `nix flake check` (validates all expressions)
2. **fmt.yml** — runs treefmt check on `**.nix` files via `nix-fast-build`
