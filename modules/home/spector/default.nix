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
    ./services
    ./shell
    ./theming
    ./editors
  ];

}
