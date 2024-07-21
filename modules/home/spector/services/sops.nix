{ inputs, config, ... }:
let
  secretsPath = builtins.toString inputs.nix-secrets;
  secretsFile = "${secretsPath}/secrets.yaml";
  inherit (config.home) homeDirectory;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    # This is the ta/dev key and needs to have been copied to this location on the host
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsFile}";
    validateSopsFiles = false;

    secrets = {
      "private_keys/spector" = {
        path = "${homeDirectory}/.ssh/id_spector";
      };
    };
  };
}
