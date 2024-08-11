{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkMerge;

  inherit (config.modules) display;
  cfg = config.modules.hardware;

  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.production;
in
{
  config =
    mkIf
      (builtins.elem cfg.gpu.type [
        "nvidia"
        "hybrid-nv"
      ])
      {
        services.xserver = mkMerge [
          { videoDrivers = [ "nvidia" ]; }

          # xorg settings
          (mkIf (!display.isWayland) {
            # disable DPMS
            monitorSection = ''
              Option "DPMS" "false"
            '';

            # disable screen blanking in general
            serverFlagsSection = ''
              Option "StandbyTime" "0"
              Option "SuspendTime" "0"
              Option "OffTime" "0"
              Option "BlankTime" "0"
            '';
          })
        ];

        environment = {
          sessionVariables = mkMerge [
            { LIBVA_DRIVER_NAME = "nvidia"; }

            (mkIf display.isWayland {
              __GL_VRR_ALLOWED = "1";
              __GL_GSYNC_ALLOWED = "1";
              # Perhaps breaks firefox
              # GBM_BACKEND = "nvidia-drm";
            })

            (mkIf (display.isWayland && (cfg.gpu == "hybrid-nv")) {
              #__NV_PRIME_RENDER_OFFLOAD = "1";
              #WLR_DRM_DEVICES = mkDefault "/dev/dri/card1:/dev/dri/card0";
            })

            (mkIf (display.isWayland && (cfg == "vm")) { WLR_RENDERER_ALLOW_SOFTWARE = "1"; })
          ];
          systemPackages = with pkgs; [
            nvtopPackages.nvidia

            # mesa
            mesa

            # vulkan
            vulkan-tools
            vulkan-loader
            vulkan-validation-layers
            vulkan-extension-layer

            # libva
            libva
            libva-utils
          ];
        };

        hardware = {
          nvidia = {
            package = mkDefault nvidiaPackage;
            modesetting.enable = mkDefault true;

            prime.offload =
              let
                isHybrid = cfg.gpu == "hybrid-nv";
              in
              {
                enable = isHybrid;
                enableOffloadCmd = isHybrid;
              };

            powerManagement = {
              enable = mkDefault true;
              finegrained = mkDefault false;
            };

            nvidiaSettings = false;
            nvidiaPersistenced = true;
            forceFullCompositionPipeline = true;
          };
        };
      };
}
