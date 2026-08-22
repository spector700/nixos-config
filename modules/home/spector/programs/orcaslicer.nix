{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  orcaSlicerWithBambuddyCert =
    pkgs.runCommand "orca-slicer-${pkgs.orca-slicer.version}"
      {
        nativeBuildInputs = [ pkgs.perl ];
        meta = pkgs.orca-slicer.meta;
      }
      ''
        mkdir -p "$out"
        cp -aL "${pkgs.orca-slicer}/." "$out/"

        old_package="${pkgs.orca-slicer}"
        old_hash="''${old_package#/nix/store/}"
        old_hash="''${old_hash%%-*}"
        new_hash="''${out#/nix/store/}"
        new_hash="''${new_hash%%-*}"
        test "''${#old_hash}" -eq 32
        test "''${#new_hash}" -eq 32

        chmod u+w "$out/bin"
        for launcher in "$out/bin/orca-slicer" "$out/bin/.orca-slicer-wrapped"; do
          rewritten_launcher="$TMPDIR/$(basename "$launcher")"
          cp "$launcher" "$rewritten_launcher"
          mv "$rewritten_launcher" "$launcher"
          OLD_HASH="$old_hash" NEW_HASH="$new_hash" \
            perl -0pi -e 's/\Q$ENV{OLD_HASH}\E/$ENV{NEW_HASH}/g' "$launcher"
        done

        certificate="$out/share/OrcaSlicer/cert/printer.cer"
        chmod u+w "$certificate"
        original_certificate="$TMPDIR/printer.cer.original"
        cp "$certificate" "$original_certificate"
        cat "${./bambuddy-virtual-printer-ca.crt}" > "$certificate"
        printf '\n' >> "$certificate"
        cat "$original_certificate" >> "$certificate"
      '';

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
        # use zink workaround for nvidia, see:
        # https://github.com/klylabs/OrcaSlicer/blob/5d6bc146e8b6a1eba7db78d2c6a706f51d49ec67/src/platform/unix/BuildLinuxImage.sh.in#L60
        postBuild = # sh
          ''
            wrapProgram $out/bin/${bin} \
              --set __GLX_VENDOR_LIBRARY_NAME mesa \
              --set __EGL_VENDOR_LIBRARY_FILENAMES ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json \
              --set MESA_LOADER_DRIVER_OVERRIDE zink \
              --set GALLIUM_DRIVER zink \
              --set WEBKIT_DISABLE_DMABUF_RENDERER 1
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
      # (nvidiaSoftwareRenderingWorkaround "orca-slicer" orcaSlicerWithBambuddyCert)
      orcaSlicerWithBambuddyCert
      # associate step files with orca-slicer
      (pkgs.writeTextFile {
        name = "model-step.xml";
        text = # xml
          ''
            <?xml version="1.0" encoding="UTF-8"?>
            <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
                <mime-type type="model/step">
                    <glob pattern="*.step"/>
                    <glob pattern="*.stp"/>
                    <comment>STEP CAD File</comment>
                </mime-type>
            </mime-info>
          '';
        executable = true;
        destination = "/share/mime/packages/model-step.xml";
      })
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
