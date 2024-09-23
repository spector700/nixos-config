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
            # vulkan-validation-layers
            vulkan-extension-layer

            # libva
            libva
            libva-utils
          ];
        };

        # Fix for firefox crashing on 560
        # environment.etc =
        #   let
        #     mkEglFile =
        #       n: library:
        #       let
        #         suffix = lib.optionalString (library != "wayland") ".1";
        #         pkg = if library != "wayland" then config.hardware.nvidia.package else pkgs.egl-wayland;
        #
        #         fileName = "${toString n}_nvidia_${library}.json";
        #         library_path = "${pkg}/lib/libnvidia-egl-${library}.so${suffix}";
        #       in
        #       {
        #         "egl/egl_external_platform.d/${fileName}".source = pkgs.writeText fileName (
        #           builtins.toJSON {
        #             file_format_version = "1.0.0";
        #             ICD = {
        #               inherit library_path;
        #             };
        #           }
        #         );
        #       };
        #   in
        #   {
        #     "egl/egl_external_platform.d".enable = false;
        #   }
        #   // mkEglFile 10 "wayland"
        #   // mkEglFile 15 "gbm"
        #   // mkEglFile 20 "xcb"
        #   // mkEglFile 20 "xlib";

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
              enable = mkDefault true;
              finegrained = mkDefault false;
            };

            nvidiaSettings = false;
            nvidiaPersistenced = true;
          };
        };
      };
}
