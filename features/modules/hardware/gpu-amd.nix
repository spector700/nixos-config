_: {
  flake.aspects.gpu-amd.nixos =
    {
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkDefault;
    in
    {
      services.xserver.videoDrivers = mkDefault [
        "modesetting"
        "amdgpu"
      ];

      boot = {
        initrd.kernelModules = [ "amdgpu" ];
        kernelModules = [ "amdgpu" ];
      };

      environment.systemPackages = [ pkgs.nvtopPackages.amd ];

      hardware.graphics = {
        extraPackages = [
          pkgs.amdvlk
          pkgs.mesa
          pkgs.vulkan-tools
          pkgs.vulkan-loader
          pkgs.vulkan-validation-layers
          pkgs.vulkan-extension-layer
        ]
        ++ (
          if pkgs ? rocmPackages.clr then
            [
              pkgs.rocmPackages.clr
              pkgs.rocmPackages.clr.icd
            ]
          else
            [
              pkgs.rocm-opencl-icd
              pkgs.rocm-opencl-runtime
            ]
        );
        extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
      };
    };
}
