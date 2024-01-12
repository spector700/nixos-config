{ lib, pkgs, ... }: {
  networking.networkmanager.enable = true;

  services = {
    openssh = {
      enable = true; # local: $ ssh <user>@<ip>
      # generating a key:
      #   - $ ssh-keygen   |  ssh-copy-id <ip/domain>  |  ssh-add
      #   - if ssh-add does not work: $ eval `ssh-agent -s` or eval $(ssh-agent)
      # connect: $ sftp <user>@<ip/domain>
      #   or with file browser: sftp://<ip address>
      # commands:
      #   - lpwd & pwd = print (local) parent working directory
      #   - put/get <filename> = send or receive file
    };
  };

  # Network wait fails with networkmanager
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;
}
