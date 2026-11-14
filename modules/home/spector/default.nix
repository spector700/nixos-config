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
    ./shell
    ./theming
  ];

}
