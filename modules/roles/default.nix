{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.modules = {
    host = mkOption {
      type = types.enum [
        "laptop"
        "desktop"
        "server"
        "hybrid"
        "lite"
        "vm"
      ];
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
  };
}
