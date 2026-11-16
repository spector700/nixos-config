# AGENTS.md — NixOS Configuration

## Repository overview

NixOS flake using flake-parts, flake-aspects, import-tree, Home Manager, Disko,
sops-nix and impermanence. Hosts: `alfheim` (x86_64 Hyprland desktop), `vivo`
(x86_64 Niri laptop) and `vanaheim` (server; inspect its hardware configuration
before assuming its architecture).

## Layout and composition

```text
flake.nix                     inputs, systems, module imports and host outputs
flake/                        formatting, hooks and development shell
hosts/_hosts.nix              nixosSystem helper and host registrations
hosts/<host>/<host>.nix        host aspect and feature selection
hosts/<host>/_hardware-configuration.nix
features/                     reusable aspects, grouped by feature
features/disko/               Disko aspect and disk layout
features/programs/ai/_ai-tools/  AI instructions, agents and skills
lib/                          custom lib' helpers
pkgs/                         package and overlay flake modules
```

`import-tree` discovers flake-parts modules under `features/` and `hosts/`;
underscore-prefixed files or directories are excluded and must be explicitly
imported. `flake.aspects.<name>` may define `nixos`, `homeManager`, and
`includes`; resolved modules are exposed as `self.modules.<class>.<name>`.
Selecting an aspect can enable its feature directly—do not assume every
feature has a separate enable option. Keep NixOS and Home Manager pieces of a
feature together where practical.

`hosts/_hosts.nix` passes `inputs`, `self`, `lib'`, and `location` to NixOS.
The Home Manager aspect passes `inputs`, `self`, and `location` as extra
arguments. `inputs'` is a flake-parts per-system argument, not a normal NixOS
or Home Manager argument; use `moduleWithSystem` where needed. `location` is
the writable checkout path, not the Nix store source path.

Custom options generally live under `modules.*`; use existing patterns and
avoid unnecessary option surfaces. See
`features/programs/ai/_ai-tools/skills/writing-nix/SKILL.md` for style.

## Validation and deployment

```bash
nix fmt
deadnix .
nix flake check
nix build .#checks.x86_64-linux.treefmt
nix build .#checks.x86_64-linux.pre-commit
nix build .#nixosConfigurations.alfheim.config.system.build.toplevel
```

`nix flake check` may not force every host's full system derivation; build the
relevant host as well. `--all-systems` includes other systems and may require
appropriate builders or emulation. Add new files to Git before Git-flake
evaluation. Avoid formatting unrelated user changes. Hooks include actionlint,
luacheck, secret detection, whitespace, symlink, EOF and treefmt checks;
consult `flake/pre-commit-hooks.nix` for actual exclusions.

`just diff <host>` compares the local active system against the specified host
build. `just rebuild-deploy <host>` switches the remote host over SSH port
5010; never deploy without authorization. Disko formatting is destructive;
never run it without explicit approval and verification of target disks.
Protect remote SSH access, SOPS keys and persistent data. Never discard user
changes, commit secrets, or assume a successful evaluation is a runtime test.
