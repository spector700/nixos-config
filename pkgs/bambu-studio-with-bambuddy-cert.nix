{ pkgs }:
let
  bambuStudio = pkgs.bambu-studio.override {
    withNvidiaGLWorkaround = true;
  };
in
pkgs.runCommand "bambu-studio-${bambuStudio.version}"
  {
    nativeBuildInputs = [ pkgs.perl ];
    passthru.basePackage = bambuStudio;
    meta = bambuStudio.meta // {
      description = "Bambu Studio with the Bambuddy virtual-printer CA";
    };
  }
  ''
    mkdir -p "$out"
    cp -aL "${bambuStudio}/." "$out/"

    old_package="${bambuStudio}"
    new_package="$out"
    old_hash="''${old_package#/nix/store/}"
    old_hash="''${old_hash%%-*}"
    new_hash="''${new_package#/nix/store/}"
    new_hash="''${new_hash%%-*}"
    test "''${#old_hash}" -eq "''${#new_hash}"
    chmod u+w "$out/bin"

    for launcher in "$out/bin/bambu-studio" "$out/bin/.bambu-studio-wrapped"; do
      rewritten_launcher="$TMPDIR/$(basename "$launcher")"
      cp "$launcher" "$rewritten_launcher"
      mv "$rewritten_launcher" "$launcher"
      OLD_HASH="$old_hash" NEW_HASH="$new_hash" \
        perl -0pi -e 's/\Q$ENV{OLD_HASH}\E/$ENV{NEW_HASH}/g' "$launcher"
    done

    certificate="$out/share/BambuStudio/cert/printer.cer"
    test -f "$certificate"
    chmod u+w "$certificate"
    original_certificate="$TMPDIR/printer.cer.original"
    cp "$certificate" "$original_certificate"
    cat "${../modules/home/spector/programs/bambuddy-virtual-printer-ca.crt}" > "$certificate"
    printf '\n' >> "$certificate"
    cat "$original_certificate" >> "$certificate"
    rm "$original_certificate"
  ''
