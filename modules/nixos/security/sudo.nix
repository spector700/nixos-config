{ lib, ... }:
let
  inherit (lib) mkForce mkDefault;
in
{
  security = {
    # https://github.com/NixOS/nixpkgs/pull/256491
    sudo-rs.enable = mkForce false;

    sudo = {
      # User does not need to give password when using sudo.
      wheelNeedsPassword = mkDefault false;

      # only allow members of the wheel group to execute sudo
      # by setting the executable’s permissions accordingly
      execWheelOnly = mkForce true;
    };
  };
}
