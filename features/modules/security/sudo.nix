_: {
  flake.aspects.sudo.nixos =
    { lib, ... }:
    let
      inherit (lib) mkForce mkDefault;
    in
    {
      security = {
        sudo = {
          # User does not need to give password when using sudo.
          wheelNeedsPassword = mkDefault false;

          # only allow members of the wheel group to execute sudo
          # by setting the executable’s permissions accordingly
          execWheelOnly = mkForce true;
        };
      };
    };
}
