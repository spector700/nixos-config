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
statix check .                  # Lint .nix files for anti-patterns
deadnix .                       # Find unused variables/imports
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

## Code Style Guidelines

### Formatter
- **nixfmt** formats all `.nix` files — run `nix fmt` before committing
- **shfmt** formats shell scripts
- 2-space indentation (nixfmt default)

### Module Boilerplate Pattern
Every NixOS module follows this structure:

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
    # actual config
  };
}
```

### Custom Option Namespace
Custom options live under `modules.*` for all NixOS and homelab service modules. Never modify
top-level NixOS namespaces directly in module option declarations. Examples: `modules.boot`,
`modules.hardware`, `modules.roles.gaming`, `modules.services.sunshine`,
`modules.homelab.grafana`.

**Exception — `homelab.*` infrastructure options:** The homelab system additionally exposes a
top-level `homelab.*` namespace for shared infrastructure facts (not service enablement):
```nix
homelab.domain          # default "homelab.local"
homelab.host            # submodule: hostname, description, interface, address, gateway, nproc
homelab.portRegistry    # attrs: central port registry (HTTP port = 10000 + appId)
homelab.podmanBaseStorage  # default "/data/podman"
```
These are defined in `modules/nixos/homelab/default.nix` and set in host configs directly
(not under `modules.*`). Service enablement still uses `modules.homelab.<name>.enable`.

### specialArgs
Four values are always in scope via `specialArgs`:
- `inputs` — flake inputs attrset
- `self` — the flake itself
- `lib'` — custom lib (`import ./lib`, contains `isx86Linux`)
- `location` — string `"/home/spector/nixos-config"`

Consume them in module args:
```nix
{ pkgs, inputs, location, lib', ... }:
```

### mkIf / mkMerge
Use `mkIf cfg.enable (mkMerge [ { ... } { ... } ])` when a module has multiple
conditional blocks. Use bare `mkIf cfg.enable { ... }` for simple cases.

### mkDefault vs mkForce
- `mkDefault` — overridable by host config (priority 1000)
- `mkForce` — overrides all (priority 50), use sparingly for host-level overrides

### Types
```nix
types.nullOr (types.enum [ "intel" "amd" "vm-amd" ])   # CPU type options
types.str                                                 # Free-form string
types.bool                                                # Boolean (prefer mkEnableOption)
types.listOf types.str                                    # List of strings
```

### Naming Conventions
| Thing | Convention | Example |
|---|---|---|
| Directories | kebab-case | `modules/nixos/boot/`, `modules/home/spector/shell/` |
| Nix files | kebab-case or `default.nix` | `sunshine.nix`, `default.nix` |
| Hostnames | single-word mythological | `alfheim`, `vivo`, `vanaheim` |
| Nix attributes | camelCase (NixOS convention) | `enableKernelTweaks`, `mainUser` |
| Local variables | camelCase | `cfg`, `lib'`, `user`, `location` |
| Custom options path | dot-separated kebab | `modules.roles.gaming`, `modules.hardware.cpu.type` |

### `cfg` Shorthand
Always bind the module's option set to `cfg`:
```nix
cfg = config.modules.services.sunshine;
```

### `inherit` Usage
Use multi-line inherit for 3+ symbols:
```nix
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkMerge
    ;
in
```

### home-manager Modules
Home-manager modules under `modules/home/spector/` do NOT need `options` declarations —
they directly configure `programs.*`, `services.*`, `home.*` etc:

```nix
{ config, pkgs, inputs, location, ... }:
{
  imports = [ inputs.some-flake.homeManagerModules.default ];

  programs.git = {
    enable = true;
    # ...
  };
}
```

### Impermanence Integration
Modules that manage stateful services should conditionally persist their data directories.
Check whether impermanence is enabled before adding persistence entries:

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

This pattern appears in homelab service modules (grafana, loki, etc.) and ensures
stateful data survives reboots on hosts with a tmpfs/ephemeral root.

### sops-nix Secrets
Secrets come from the private `nix-secrets` flake input (SSH git URL, `flake=false`).

NixOS secret reference:
```nix
users.users.spector.hashedPasswordFile = config.sops.secrets."users/spector/password".path;
```

Home-manager secret reference:
```nix
sops.secrets."keys/ssh/spector_alfheim" = {
  path = "/home/spector/.ssh/id_spector";
};
```

### Imports in Host Configs
```nix
modules = [
  ./alfheim               # host-specific
  ../modules/nixos        # shared NixOS modules
]
++ concatLists [ homeManager ];  # home-manager via concatLists
```

---

## Common Pitfalls

- **Do not** use `nix-env` or imperative commands — everything is declarative
- **Do not** add options outside the `modules.*` namespace for custom options (exception: `homelab.*` infrastructure options — see Custom Option Namespace above)
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
