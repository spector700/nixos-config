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

    settings = {
      ${builtins.concatStringsSep " " hostnames} = {
        ForwardAgent = true;
        Compression = true;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = true;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      "github.com" = {
        HostName = "github.com";
        IdentityFile = "${homeDirectory}/.ssh/gitkey";
      };

      "vanaheim" = {
        HostName = "2a01:4f9:c010:eb77::1";
        User = user;
        IdentityFile = "${homeDirectory}/.ssh/id_spector";
      };
    };
  };
}
