{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (lib) optionalString;
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;

  secretsPath = builtins.toString inputs.nix-secrets;

  isPersistence = config.modules.boot.impermanence.enable;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;

    age = {
      # automatically import host SSH keys as age keys
      sshKeyPaths = map getKeyPath keys;
      # key that is expected to already be in the file system
      keyFile = "${optionalString isPersistence "/persist"}/var/lib/sops-nix/key.txt";
      # This will generate a new key if the key specified above does not exist
      generateKey = true;
    };

    secrets.spector-password.neededForUsers = true;
  };
}
