# Adding and bootstrapping a host

## Configure the host

1. Create `hosts/<host>/<host>.nix` as a flake-parts module defining
   `flake.aspects.<host>`. Select existing features with `includes`, set
   host-specific NixOS settings, and add a `homeManager` block if needed. Use an
   existing host as a template.
2. Generate and review a hardware configuration for the target and import it
   explicitly from the host aspect, for example `./_hardware-configuration.nix`.
   import-tree skips underscore-prefixed paths.
3. Register the host in `hosts/_hosts.nix`, for example
   `myhost = mkHost "myhost" { homeManager = true; };`. The helper defaults to
   no Home Manager. For Home Manager, include `aspects.home-manager` and ensure
   the host aspect provides a Home Manager class; the helper currently assigns
   it to `spector`. A host without Home Manager must not depend on it.
4. Configure networking, the main user, SOPS secrets and SSH access. For a
   remote host verify the interface, addresses, gateway, credentials and port
   before switching; the existing SSH aspect uses port 5010.
5. If selecting `lvm-btrfs`, set `modules.disko.disk` to the intended target
   device. Review `features/disko/lvm-btrfs.nix` and the impermanence aspect:
   they assume a particular LVM/Btrfs layout and root volume.
6. Add the new files to Git so the flake can see them, then evaluate and build:

   ```bash
   just check
   rebuild
   ```

   A build does not format disks or activate the configuration. Cross-system
   builds may require an appropriate builder or emulation.

## Installation and deployment

**Disko installation can erase the target disk.** Back up data and independently
verify the device and layout before running any formatting or bootstrap command.
Review `hosts/bootstrap.sh` and `hosts/helpers.sh` before use: they encode
repository-specific secrets paths, SSH assumptions and installation behavior.
The script's `--help` describes its arguments; `--impermanence` assumes
`/persist`. Generated hardware configuration goes to
`hosts/<host>/_hardware-configuration.nix`; an existing file is not overwritten.
The host aspect must import it. SSH host-key checking is disabled by parts of
the script, so verify fingerprints independently. No bootstrap or deployment
has been tested by these instructions.

For an existing machine, `just diff <host>` compares the **local** active
generation with a freshly built host configuration. To deploy over SSH port
5010, use `just rebuild-deploy <host>` only after checking target access and the
configuration. It performs a remote switch; it is not a dry run.
