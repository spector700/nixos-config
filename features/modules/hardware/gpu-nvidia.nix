_: {
  flake.aspects.gpu-nvidia.nixos =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib)
        mkIf
        mkDefault
        mkMerge
        mkOption
        types
        ;
      inherit (config.modules) desktop;
      cfg = config.modules.hardware;
    in
    {

      options.modules.hardware = {
        gpu = mkOption {
          type =
            with types;
            nullOr (enum [
              "nvidia"
              "hybrid-nv"
            ]);
          default = null;
          description = ''
            The type of nvidia GPU.
          '';
        };
      };

      config =
        mkIf
          (builtins.elem cfg.gpu [
            "nvidia"
            "hybrid-nv"
          ])
          {
            services.xserver.videoDrivers = [ "nvidia" ];

            environment = {
              sessionVariables = mkMerge [
                {
                  LIBVA_DRIVER_NAME = "nvidia";
                  # Remove NVIDIA's default 128MB shader cache cap.
                  __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
                }
                (mkIf desktop.isWayland {
                  __GL_VRR_ALLOWED = "1";
                  __GL_GSYNC_ALLOWED = "1";
                })
                (mkIf (cfg.gpu == "hybrid-nv") {
                  #__NV_PRIME_RENDER_OFFLOAD = "1";
                  #WLR_DRM_DEVICES = mkDefault "/dev/dri/card1:/dev/dri/card0";
                })
                (mkIf (cfg == "vm") { WLR_RENDERER_ALLOW_SOFTWARE = "1"; })
              ];
              systemPackages = [
                pkgs.nvtopPackages.nvidia
                pkgs.mesa
                pkgs.vulkan-tools
                pkgs.vulkan-loader
                pkgs.vulkan-extension-layer
                pkgs.libva
                pkgs.libva-utils
              ];
            };

            hardware.nvidia = {
              package = mkDefault config.boot.kernelPackages.nvidiaPackages.latest;
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
              # NVIDIA 595+ handles suspend via kernel notifiers.
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
