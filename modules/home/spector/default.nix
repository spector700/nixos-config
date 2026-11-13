{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  imports = [
    ./programs
    ./roles
    ./shell
    ./theming
  ];

}
