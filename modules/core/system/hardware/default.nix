{ lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
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
  };
}
