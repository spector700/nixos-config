# Git
#
{ config, ... }:
{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      ignores = [
        ".direnv"
        "result"
        "node_modules"
      ];

      settings = {
        extraConfig = {
          init = {
            defaultBranch = "main";
          };

          core.askPass = "";

          diff.colorMoved = "default";
          commit.gpgSign = true;
          gpg.format = "ssh";
          user.signingkey = "${config.home.homeDirectory}/.ssh/gitkey";

          push = {
            default = "current";
            followTags = true;
            autoSetupRemote = true;
          };
          signing = {
            signByDefault = true;
            key = "${config.home.homeDirectory}/.ssh/gitkey";
          };
        };

        user = {
          email = "72362399+spector700@users.noreply.github.com";
          name = "spector700";
        };
      };
    };
  };
}
