{ inputs
, system
, stdenv
, buildNpmPackage
, writeShellScript
, cage
, swww
, bun
, dart-sass
, fd
, hyprpicker
, pavucontrol
, networkmanager
, gtk3
, brightnessctl
, accountsservice
, webkitgtk_4_1
}:
let
  ags = inputs.ags.packages.${system}.default.override {
    extraPackages = [
      accountsservice
      webkitgtk_4_1
    ];
  };

  name = "koshi";
  version = "1.7.9";

  dependencies = [
    dart-sass
    fd
    brightnessctl
    # swww
    inputs.matugen.packages.${system}.default
    # slurp
    # wf-recorder
    # wl-clipboard
    # wayshot
    # swappy
    hyprpicker
    pavucontrol
    networkmanager
    gtk3
  ];

  addBins = list: builtins.concatStringsSep ":" (builtins.map (p: "${p}/bin") list);

  greeter = writeShellScript "greeter" ''
    export PATH=$PATH:${addBins dependencies}
    ${cage}/bin/cage -ds -m last ${ags}/bin/ags -- -c ${config}/greeter.js
  '';

  desktop = writeShellScript name ''
    export PATH=$PATH:${addBins dependencies}
    ${ags}/bin/ags -b ${name} -c ${config}/config.js $@
  '';

  config = buildNpmPackage {
    inherit name version;
    src = ./.;
    npmDepsHash = "sha256-06Lb6hmCPsJt1MIkTYg+pJbAIgnKzftf9e2Iygipr6c=";
    dontNpmBuild = true;

    buildPhase = ''
      ${bun}/bin/bun build ./main.ts \
        --outfile main.js \
        --external "resource://*" \
        --external "gi://*"

      ${bun}/bin/bun build ./greeter/greeter.ts \
        --outfile greeter.js \
        --external "resource://*" \
        --external "gi://*"
    '';

    installPhase = ''
      mkdir $out
      cp -r * $out
      cp -f main.js $out/config.js
      cp -f greeter.js $out/greeter.js
    '';
  };
in
stdenv.mkDerivation {
  inherit name;
  src = config;

  installPhase = ''
    mkdir -p $out/bin
    cp -r . $out
    cp ${desktop} $out/bin/${name}
    cp ${greeter}  $out/bin/greeter
  '';
}

