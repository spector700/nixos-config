# custom functions or variables usable with
# {lib', ...}:
# lib'.<thing> or inherit (lib') <thing>;
{
  # check if the host platform is linux and x86
  # (isx86Linux pkgs) -> true
  isx86Linux = pkgs: with pkgs.stdenv; hostPlatform.isLinux && hostPlatform.isx86;
}
