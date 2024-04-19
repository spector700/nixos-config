{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    length
    filter
    ;
  cfg = config.modules.display;
in
{
  options.modules.display = {
    monitors = mkOption {
      default = [ ];
      description = ''
        A list of monitors connected to the system.
      '';
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              example = "DP-1";
            };

            primary = mkOption {
              type = types.bool;
              default = false;
            };

            position = mkOption {
              type = types.str;
              default = "0x0";
            };

            resolution = mkOption {
              type = types.str;
              default = "preferred";
            };

            refreshRate = mkOption {
              type = types.int;
              default = 60;
            };

            scale = mkOption {
              type = types.str;
              default = "1";
            };

            rotation = mkOption {
              type = types.str;
              default = "";
              description = ''
                normal (no transforms) -> 0
                90 degrees -> 1
                180 degrees -> 2
                270 degrees -> 3
                flipped -> 4
                flipped + 90 degrees -> 5
                flipped + 180 degrees -> 6
                flipped + 270 degrees -> 7
              '';
            };

            workspaces = mkOption {
              type = with types; listOf int;
              description = ''
                [1 2 3]
              '';
            };
          };
        }
      );
    };
  };

  config = {
    assertions = [
      {
        assertion = ((length cfg.monitors) != 0) -> ((length (filter (m: m.primary) cfg.monitors)) == 1);
        message = "Exactly one monitor must be set to primary.";
      }
    ];
  };
}
