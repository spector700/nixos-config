# Bootstrapping a new host

1. Create a config in `/hosts/<host>/default.nix`

2. Add to the file `profile.nix` and add both files to git
   ```nix
   # Homelab
   vanaheim = nixosSystem {
     inherit specialArgs;
     # Modules that are used
     modules = [
       ./vanaheim
       ../modules/nixos
     ]
     ++ concatLists [ homeManager ];
   };
   ```

   - Check for ssh access if using ssh key:
     `ssh root@<ipv4>/<ipv6> -i ~/.ssh/id_spector`

   - Get drive name from the server: `lsblk` Then add it to the disko config
   ```nix
   imports = [
     ./hardware-configuration.nix
     inputs.disko.nixosModules.disko
     (import ../disks/lvm-btrfs.nix { disks = [ "/dev/sda" ]; })
   ];
   ```

   If using IPv6, we need to set the ip address statically in the config for ssh
   to work after nixos installation.

   ```nix
      let
        macAddress = "92:00:06:ed:33:ca";
         networkInterface = "enp1s0";
         ipv6Address = "c9de:66d0:24b1:8da6:2ea5:8c27:b662:ad90::1";
         gateway = "fe80::1";
      in

      # rename the external interface based on the MAC of the interface
      services.udev.extraRules = ''SUBSYSTEM=="net", ATTR{address}=="${macAddress}", NAME="${networkInterface}"'';

      networking = {
        hostName = "vanaheim";

        interfaces."${networkInterface}" = {
          ipv6.addresses = [
            {
              address = "${ipv6Address}";
              prefixLength = 64;
            }
          ];
        };
        defaultGateway6 = {
          address = "${gateway}";
          interface = "${networkInterface}";
        };
      };
   ```

3. Use the `script.sh` for nixos-anywhere to install the config to the system.
   - `-k` for the ssh key to use
   - `--impermanence` to enable impermanence on the system.
   - `./hosts/bootstrap.sh -n vanaheim -d 192.168.1.104 -k /home/spector/.ssh/id_spector --impermanence`
