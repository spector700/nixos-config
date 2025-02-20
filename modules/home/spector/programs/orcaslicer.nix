{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  # software rendering workaround for nvidia, see:
  # https://github.com/SoftFever/OrcaSlicer/issues/6433#issuecomment-2552029299
  nvidiaSoftwareRenderingWorkaround =
    bin: pkg:
    if
      (builtins.elem osConfig.modules.hardware.gpu.type [
        "nvidia"
        "hybrid-nv"
      ])
    then
      pkgs.symlinkJoin {
        name = bin;
        paths = [ pkg ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = # sh
          ''
            wrapProgram $out/bin/${bin} \
              --set __GLX_VENDOR_LIBRARY_NAME mesa \
              --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa.drivers}/share/glvnd/egl_vendor.d/50_mesa.json
          '';
        meta.mainProgram = bin;
      }
    else
      pkg;

  inherit (lib) mkIf mkEnableOption;
  cfg = config.modules.programs.orca-slicer;
in
{
  options.modules.programs = {
    orca-slicer.enable = mkEnableOption "3d printing";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # orca-slicer doesn't show the prepare / preview pane on nvidia 565:
      # https://github.com/SoftFever/OrcaSlicer/issues/6433#issuecomment-2552029299
      (nvidiaSoftwareRenderingWorkaround "orca-slicer" orca-slicer)
    ];

    # allow orca-slicer to be open bambu studio links
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/orcaslicer" = "OrcaSlicer.desktop";
      "x-scheme-handler/bambustudio" = "OrcaSlicer.desktop"; # makerworld
      "x-scheme-handler/prusaslicer" = "OrcaSlicer.desktop"; # printables
    };
  };
}
