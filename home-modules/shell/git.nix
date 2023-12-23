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
    };
  };
}
