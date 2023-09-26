#
# Git
#

{
  programs = {
    git = {
      enable = true;

      extraConfig = {
        init = { defaultBranch = "main"; };
        diff.colorMoved = "default";
      };
    };
  };
}
