{ lib, config, inputs, pkgs, ... }:
let
  inherit (lib) mkOption types mkIf mkAfter;
  cfg = config.modules.boot.impermanence;
in
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  options.modules.boot.impermanence = {
    enable = mkOption {
      default = false;
      type = with types; bool;
      description = "Wipe root filesystem and restore blank root BTRFS subvolume on boot.";
    };

    removeTmpFilesOlderThan = mkOption {
      default = 14;
      type = with types; int;
      description = "Number of days to keep old btrfs_tmp files";
    };
  };

  config = mkIf cfg.enable {
    # users = {
    #   # This option requires you to define a password file for your users
    #   # mkpasswd -m sha-512 > /persist/passwords/spector after you confirm /persist/passwords exists
    #   mutableUsers = false;
    #
    #   # each existing user needs to have a passwordFile defined here
    #   # otherwise, they will not be available for a login
    #   # passwordFile needs to be in a volume marked with `neededForBoot = true`
    #   users = {
    #     root = {
    #       hashedPasswordFile = "/persist/passwords/root";
    #     };
    #     ${config.modules.os.mainUser} = {
    #       hashedPasswordFile = "/persist/passwords/${config.modules.os.mainUser}";
    #     };
    #   };
    # };

    boot.initrd.postDeviceCommands = mkAfter ''
      mkdir /btrfs_tmp
      mount /dev/root_vg/root /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +${builtins.toString cfg.removeTmpFilesOlderThan}); do
      delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';

    fileSystems."/persist".neededForBoot = true;

    environment = {
      systemPackages =
        let
          # Running this will show what changed during boot to potentially use for persisting
          impermanence-fsdiff = pkgs.writeShellScriptBin "impermanence-fsdiff" ''
            _mount_drive=''${1:-"$(mount | grep '.* on / type btrfs' | awk '{ print $1}')"}
            _tmp_root=$(mktemp -d)
            mkdir -p "$_tmp_root"
            sudo mount -o subvol=/ "$_mount_drive" "$_tmp_root" > /dev/null 2>&1

            set -euo pipefail

            OLD_TRANSID=$(sudo btrfs subvolume find-new $_tmp_root/root-blank 9999999)
            OLD_TRANSID=''${OLD_TRANSID#transid marker was }

            sudo btrfs subvolume find-new "$_tmp_root/root" "$OLD_TRANSID" | sed '$d' | cut -f17- -d' ' | sort | uniq |
            while read path; do
            path="/$path"
            if [ -L "$path" ]; then
            : # The path is a symbolic link, so is probably handled by NixOS already
            elif [ -d "$path" ]; then
            : # The path is a directory, ignore
            else
            echo "$path"
            fi
            done
            sudo umount "$_tmp_root"
            rm -rf "$_tmp_root"
          '';
        in
        [ impermanence-fsdiff ];

      persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/etc/NetworkManager/system-connections"
          "/etc/secureboot"
          "/var/db/sudo"
          "/var/lib/flatpak"
          "/var/lib/libvirt"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/pipewire"
          "/var/lib/systemd/coredump"
          "/var/cache/tailscale"
          "/var/lib/tailscale"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
    };
  };
}
