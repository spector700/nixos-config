{
  lib,
  ...
}:

let
  inherit (lib) types mkOption;
in
{
  imports = [
    ./bar
    ./niri
  ];

  options.modules.desktop = {
    bar = mkOption {
      type =
        with types;
        nullOr (enum [
          "dankMaterialShell"
          "noctalia"
        ]);
      default = null;
      description = "Which bar to use";
    };
  };
}
