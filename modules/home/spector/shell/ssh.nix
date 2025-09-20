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
    matchBlocks = {
      net = {
        host = builtins.concatStringsSep " " hostnames;
        forwardAgent = true;
      };
      "github.com" = {
        hostname = "github.com";
        identityFile = "${homeDirectory}/.ssh/gitkey";
        compression = true;
        hashKnownHosts = true;
      };
      "vanaheim" = {
        hostname = "192.168.1.111";
        inherit user;
        identityFile = "${homeDirectory}/.ssh/id_spector";
        compression = true;
        hashKnownHosts = true;
      };
    };
  };
}
