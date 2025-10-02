{ lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  imports = [
    ./cpu
    ./gpu
    ./power
    ./rgb
    ./bluetooth.nix
    ./printing.nix
    ./sound.nix
  ];

  options.modules.hardware = {
    # the type of cpu your system has - vm and regular cpus currently do not differ
    cpu = {
      type = mkOption {
        type =
          with types;
          nullOr (enum [
            "pi"
            "intel"
            "vm-intel"
            "amd"
            "vm-amd"
          ]);
        default = null;
        description = ''
          The manufacturer/type of the primary system CPU.

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
        type =
          with types;
          nullOr (enum [
            "pi"
            "amd"
            "intel"
            "nvidia"
            "hybrid-nv"
            "hybrid-amd"
          ]);
        default = null;
        description = ''
          The manufacturer/type of the primary system GPU.
        '';
      };
    };
  };
}
