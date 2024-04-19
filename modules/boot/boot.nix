{ config, lib, ... }:
let
  inherit (lib)
    mkDefault
    mkForce
    optionals
    mkEnableOption
    ;
  cfg = config.modules.boot;
in
{
  options.modules.boot = {
    enableKernelTweaks = mkEnableOption "security and performance related kernel parameters";
  };

  config.boot = {
    # whether to enable support for Linux MD RAID arrays
    swraid.enable = mkDefault false;

    # settings shared between bootloaders
    # they are set unless system.boot.loader != none
    loader = {
      # if set to 0, space needs to be held to get the boot menu to appear
      timeout = mkForce 1;

      # whether to copy the necessary boot files into /boot
      # so that /nix/store is not needed by the boot loader.
      generationsDir.copyKernels = true;

      # allow installation to modify EFI variables
      efi.canTouchEfiVariables = true;
    };

    kernelParams = optionals cfg.enableKernelTweaks [
      # https://en.wikipedia.org/wiki/Kernel_page-table_isolation
      # auto means kernel will automatically decide the pti state
      "pti=auto" # on | off

      # CPU idle behaviour
      #  poll: slightly improve performance at cost of a hotter system (not recommended)
      #  halt: halt is forced to be used for CPU idle
      #  nomwait: Disable mwait for CPU C-states
      "idle=nomwait" # poll | halt | nomwait

      # enable IOMMU for devices used in passthrough
      # and provide better host performance in virtualization
      "iommu=pt"

      # disable usb autosuspend
      "usbcore.autosuspend=-1"

      # disables resume and restores original swap space
      "noresume"

      # allows systemd to set and save the backlight state
      "acpi_backlight=native" # none | vendor | video | native

      # disable the cursor in vt to get a black screen during intermissions
      "vt.global_cursor_default=0"

      # disable displaying of the built-in Linux logo
      "logo.nologo"
    ];
  };
}
