# Git
#
{ config, pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      lfs.enable = true;

      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        credential.helper = "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";

        core.askPass = "";

        diff.colorMoved = "default";
        gpg.format = "ssh";

        push = {
          default = "current";
          followTags = true;
          autoSetupRemote = true;
        };
      };

      ignores = [
        "*~"
        "*.swp"
        "*result*"
        ".direnv"
        "node_modules"
      ];

      signing = {
        key = "${config.home.homeDirectory}/.ssh/gitkey";
        signByDefault = true;
      };

      userEmail = "72362399+spector700@users.noreply.github.com";
      userName = "spector700";
    };
  };
}
