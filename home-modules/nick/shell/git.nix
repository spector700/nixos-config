# Git
#
{ config, ... }: {
  programs = {
    git = {
      enable = true;

      extraConfig = {
        init = { defaultBranch = "main"; };
        diff.colorMoved = "default";
        gpg.format = "ssh";
      };

      ignores = [ "*~" "*.swp" "*result*" ".direnv" "node_modules" ];

      signing = {
        key = "${config.home.homeDirectory}/.ssh/gitkey";
        signByDefault = true;
      };

      userEmail = "72362399+spector700@users.noreply.github.com";
      userName = "spector700";
    };
  };
}
