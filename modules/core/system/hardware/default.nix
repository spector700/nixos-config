{ lib, config, ... }:
let
  inherit (lib) mkOption mkEnableOption types length filter;
  cfg = config.modules.hardware;
in
{
  imports = [
    ./cpu
    ./gpu
    ./rgb
  ];

  options.modules.hardware = {
    type = mkOption {
      type = types.enum [ "laptop" "desktop" "server" "hybrid" "lite" "vm" ];
      default = "";
      description = ''
        The type/purpose of the device that will be used within the rest of the configuration.
          - laptop: portable devices with batter optimizations
          - desktop: stationary devices configured for maximum performance
          - server: server and infrastructure
          - hybrid: provide both desktop and server functionality
          - lite: a lite device, such as a raspberry pi
          - vm: a virtual machine
      '';
    };

    # the type of cpu your system has - vm and regular cpus currently do not differ
    cpu = {
      type = mkOption {
        type = with types; nullOr (enum [ "pi" "intel" "vm-intel" "amd" "vm-amd" ]);
        default = null;
        description = ''
          The manifaturer/type of the primary system CPU.

          Determines which ucode services will be enabled and provides additional kernel packages
        '';
      };

      amd = {
        pstate.enable = mkEnableOption "AMD P-State Driver";
        zenpower = {
          enable = mkEnableOption "AMD Zenpower Driver";
          args = mkOption {
            type = types.str;
            default = "-p 0 -v 3C -f A0"; # Pstate 0, 1.175 voltage, 4000 clock speed
            description = ''
              The percentage of the maximum clock speed that the CPU will be limited to.

              This is useful for reducing power consumption and heat generation on laptops
              and desktops
            '';
          };
        };
      };
    };

    gpu = {
      type = mkOption {
        type = with types; nullOr (enum [ "pi" "amd" "intel" "nvidia" "hybrid-nv" "hybrid-amd" ]);
        default = null;
        description = ''
          The manifaturer/type of the primary system GPU. 
        '';
      };
    };

    monitors = mkOption {
      type = types.listOf (types.submodule {
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
      });

      default = [ ];
      description = ''
        A list of monitors connected to the system.
      '';
    };
  };
  config = {
    assertions = [{
      assertion = ((length cfg.monitors) != 0) ->
        ((length (filter (m: m.primary) cfg.monitors)) == 1);
      message = "Exactly one monitor must be set to primary.";
    }];
  };
}
