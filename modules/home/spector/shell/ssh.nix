{ self, ... }:
let
  hostnames = builtins.attrNames self.nixosConfigurations;
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
        identityFile = "~/.ssh/gitkey";
      };
    };
  };
}
