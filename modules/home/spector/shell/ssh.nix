{
  self,
  osConfig,
  config,
  ...
}:
let
  hostnames = builtins.attrNames self.nixosConfigurations;
  inherit (config.home) homeDirectory;
  user = osConfig.modules.os.mainUser;
in
{
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
        identityFile = "${homeDirectory}/.ssh/gitkey";
      };
      "vanaheim" = {
        hostname = "192.168.1.107";
        inherit user;
        identityFile = "${homeDirectory}/.ssh/id_spector";
      };
    };
  };
}
