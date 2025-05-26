{
  inputs,
  config,
  osConfig,
  ...
}:
let
  secretsFolder = (builtins.toString inputs.nix-secrets) + "/sops";
  inherit (config.home) homeDirectory;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    # This is the age key and needs to have been copied to this location on the host
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsFolder}/${osConfig.networking.hostName}.yaml";
    validateSopsFiles = false;
  };
}
