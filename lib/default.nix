{ lib, ... }:
{
  _module.args = {
    colors = import ./colors.nix lib;
  };
}
