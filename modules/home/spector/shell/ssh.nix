{
  self,
  osConfig,
  config,
  ...
}:
let
  hostnames = builtins.attrNames self.nixosConfigurations;
  inherit (config.home) homeDirectory;
in
{

  sops.secrets = {
    "keys/ssh/${osConfig.modules.os.mainUser}_${osConfig.networking.hostName}" = {
      path = "${homeDirectory}/.ssh/id_spector";
    };
  };

  programs.ssh = {
    enable = true;
    hashKnownHosts = true;
    compression = true;
    matchBlocks = {
      net = {
        host = builtins.concatStringsSep " " hostnames;
        forwardAgent = true;
      };
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/gitkey";
      };
    };
  };
}
