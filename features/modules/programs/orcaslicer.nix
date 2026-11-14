_: {
  flake.aspects.orcaslicer.homeManager =
    {
      osConfig,
      pkgs,
      ...
    }:
    let
      orcaSlicer =
        if
          builtins.elem osConfig.modules.hardware.gpu [
            "nvidia"
            "hybrid-nv"
          ]
        then
          pkgs.symlinkJoin {
            name = "orca-slicer-patched";
            paths = [ pkgs.orca-slicer ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            # Route OpenGL through Vulkan on NVIDIA to fix the blank viewport.
            # https://github.com/OrcaSlicer/OrcaSlicer/issues/8372
            postBuild = ''
              wrapProgram "$out/bin/orca-slicer" \
                --set __GLX_VENDOR_LIBRARY_NAME mesa \
                --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json \
                --set MESA_LOADER_DRIVER_OVERRIDE zink \
                --set GALLIUM_DRIVER zink \
                --set WEBKIT_DISABLE_DMABUF_RENDERER 1
            '';
            meta = pkgs.orca-slicer.meta;
          }
        else
          pkgs.orca-slicer;
    in
    {
      home.packages = [
        orcaSlicer
      ];
      #
      # # allow orca-slicer to be open bambu studio links
      # xdg.mimeApps = {
      #   associations.added."model/step" = "OrcaSlicer.desktop";
      #   defaultApplications = {
      #     "model/step" = "OrcaSlicer.desktop";
      #     "x-scheme-handler/orcaslicer" = "OrcaSlicer.desktop";
      #     "x-scheme-handler/bambustudio" = "OrcaSlicer.desktop"; # makerworld
      #     "x-scheme-handler/prusaslicer" = "OrcaSlicer.desktop"; # printables
      #   };
      # };
    };
}
