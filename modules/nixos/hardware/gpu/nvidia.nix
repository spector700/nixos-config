{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkMerge;

  inherit (config.modules.display) desktop;
  cfg = config.modules.hardware;

  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.latest;
in
{
  config =
    mkIf
      (builtins.elem cfg.gpu.type [
        "nvidia"
        "hybrid-nv"
      ])
      {
        services.xserver = mkMerge [ { videoDrivers = [ "nvidia" ]; } ];

        environment = {
          sessionVariables = mkMerge [
            { LIBVA_DRIVER_NAME = "nvidia"; }

            (mkIf desktop.isWayland {
              __GL_VRR_ALLOWED = "1";
              __GL_GSYNC_ALLOWED = "1";
              NIXOS_OZONE_WL = "1";
              QT_QPA_PLATFORM = "wayland";
              QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
            })

            (mkIf (desktop.isWayland && (cfg.gpu == "hybrid-nv")) {
              #__NV_PRIME_RENDER_OFFLOAD = "1";
              #WLR_DRM_DEVICES = mkDefault "/dev/dri/card1:/dev/dri/card0";
            })

            (mkIf (desktop.isWayland && (cfg == "vm")) { WLR_RENDERER_ALLOW_SOFTWARE = "1"; })
          ];
          systemPackages = with pkgs; [
            nvtopPackages.nvidia

            # mesa
            mesa

            # vulkan
            vulkan-tools
            vulkan-loader
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
            open = false;

            prime.offload =
              let
                isHybrid = cfg.gpu == "hybrid-nv";
              in
              {
                enable = isHybrid;
                enableOffloadCmd = isHybrid;
              };

            powerManagement = {
              enable = mkDefault false;
              finegrained = mkDefault false;
            };

            nvidiaSettings = false;
            nvidiaPersistenced = true;
          };
        };
      };
}
