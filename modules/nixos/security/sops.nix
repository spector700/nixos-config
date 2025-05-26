{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) optionalString;
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;

  secretsPath = (builtins.toString inputs.nix-secrets) + "/sops";

  isPersistence = config.modules.boot.impermanence.enable;
  inherit (config.networking) hostName;
  user = config.modules.os.mainUser;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    age
    ssh-to-age
    sops
  ];

  sops = {
    defaultSopsFile = "${secretsPath}/${hostName}.yaml";
    validateSopsFiles = false;

    age = {
      # automatically import host SSH keys as age keys
      # maps to ["/persist/etc/ssh/ssh_host_ed25519_key"]
      sshKeyPaths = map getKeyPath keys;
      # key that is expected to already be in the file system
      # keyFile = "${optionalString isPersistence "/persist"}/var/lib/sops-nix/key.txt";
      keyFile = "/home/${user}/.config/sops/age/keys.txt";
      # This will generate a new key if the key specified above does not exist
      generateKey = true;
    };
    # secrets will be output to /run/secrets
    # e.g. /run/secrets/msmtp-password
    # because they will be output to /run/secrets-for-users and only when the user is assigned to a host.

    secrets = {
      # These age keys are are unique for the user on each host and are generated on their own (i.e. they are not derived
      # from an ssh key).

      "keys/age" = {
        owner = user;
        inherit (config.users.users.${user}) group;
        # We need to ensure the entire directory structure is that of the user...
        # path = "/home/${user}/.config/sops/age/keys.txt";
      };
      # extract password/username to /run/secrets-for-users/ so it can be used to create the user
      "passwords/${user}" = {
        sopsFile = "${secretsPath}/shared.yaml";
        neededForUsers = true;
      };
    };
  };
  # The containing folders are created as root and if this is the first ~/.config/ entry,
  # the ownership is busted and home-manager can't target because it can't write into .config...
  # FIXME(sops): We might not need this depending on how https://github.com/Mic92/sops-nix/issues/381 is fixed
  system.activationScripts.sopsSetAgeKeyOwnership =
    let
      ageFolder = "/home/${user}/.config/sops/age";
      inherit (config.users.users.${user}) group;
    in
    ''
      mkdir -p ${ageFolder} || true
      chown -R ${user}:${group} /home/${user}/.config
    '';
}
