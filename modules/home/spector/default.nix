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
    ./shell
    ./theming
  ];

}
