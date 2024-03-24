{ config, lib, ... }:
let
  inherit (lib) mkIf;
in
{
  # discard blocks that are not in use by the filesystem, good for SSDs
  services.fstrim = {
    # we may enable this unconditionally across all systems becuase it's performance
    # impact is negligible on systems without a SSD - which means it's a no-op with
    # almost no downsides aside from the service firing once per week
    enable = true;

    # the default value, good enough for average-load systems
    interval = "weekly";
  };

  # tweak fstim service to run only when on AC power
  # and to be nice to other processes
  # (this is a good idea for any service that runs periodically)
  systemd.services.fstrim = {
    unitConfig.ConditionACPower = true;

    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };

  # compress half of the ram to use as swap
  # basically, get more memory per memory
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 90; # defaults to 50
  };

  # <https://www.kernel.org/doc/html/latest/admin-guide/sysctl/vm.html>
  boot.kernel.sysctl = mkIf config.zramSwap.enable {
    # level of reclaim when memory is being fragmented
    "vm.watermark_boost_factor" = 0; # 0 to disable
    # aggressiveness of kswapd
    # it defines the amount of memory left in a node/system before kswapd is woken up
    "vm.watermark_scale_factor" = 125; # 0-300
    # zram is in memory, no need to readahead
    # page-cluster refers to the number of pages up to which
    # consecutive pages are read in from swap in a single attempt
    "vm.page-cluster" = 0;
  };
}
