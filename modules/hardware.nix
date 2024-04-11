{ config, lib, pkgs, lib', ... }:
let
  inherit (lib') isx86Linux;
  cfg = config.local.hardware;
in
{

  options.local.hardware = {
    gpuAcceleration.enable = lib.mkEnableOption "";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.gpuAcceleration.enable {
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = isx86Linux pkgs; # if we're on x86 linux, we can support 32 bit
      };
    })
  ];
}
