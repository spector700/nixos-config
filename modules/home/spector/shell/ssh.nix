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
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        host = builtins.concatStringsSep " " hostnames;
        forwardAgent = true;
        compression = true;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = true;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      "github.com" = {
        hostname = "github.com";
        identityFile = "${homeDirectory}/.ssh/gitkey";
      };

      "vanaheim" = {
        hostname = "2a01:4f9:c010:eb77::1";
        inherit user;
        identityFile = "${homeDirectory}/.ssh/id_spector";
      };
    };
  };
}
