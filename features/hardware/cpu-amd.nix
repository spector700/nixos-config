_: {
  flake.aspects.cpu-amd.nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib)
        mkIf
        mkMerge
        versionOlder
        versionAtLeast
        ;
      dev = config.modules.hardware;
      kver = config.boot.kernelPackages.kernel.version;
      inherit (lib) mkOption mkEnableOption types;
      inherit (dev.cpu.amd) pstate zenpower;
    in
    {

      options.modules.hardware = {
        # the type of cpu your system has - vm and regular cpus currently do not differ
        cpu = {
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
      };

      config = {
        hardware.cpu.amd.updateMicrocode = true;

        boot = mkMerge [
          {
            kernelModules = [
              "kvm-amd"
              "amd-pstate"
              "zenpower"
              "msr"
            ];
            extraModulePackages = [ config.boot.kernelPackages.zenpower ];
          }
          (mkIf (pstate.enable && versionAtLeast kver "5.17" && versionOlder kver "6.1") {
            kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
            kernelModules = [ "amd-pstate" ];
          })
          (mkIf (pstate.enable && versionAtLeast kver "6.1" && versionOlder kver "6.3") {
            kernelParams = [ "amd_pstate=passive" ];
          })
          (mkIf (pstate.enable && versionAtLeast kver "6.3") {
            kernelParams = [ "amd_pstate=active" ];
          })
        ];

        systemd.services.zenstates = mkIf zenpower.enable {
          enable = true;
          description = "Undervolt via Zenstates";
          after = [
            "syslog.target"
            "systemd-modules-load.service"
          ];
          unitConfig.ConditionPathExists = "${pkgs.zenstates}/bin/zenstates";
          serviceConfig = {
            User = "root";
            ExecStart = "${pkgs.zenstates}/bin/zenstates ${zenpower.args}";
          };
          wantedBy = [ "multi-user.target" ];
        };
      };
    };
}
