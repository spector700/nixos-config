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
    ./desktop
    ./programs
    ./roles
    ./services
    ./shell
    ./theming
    ./editors
  ];

}
