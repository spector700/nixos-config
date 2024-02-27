{ inputs
, system
, stdenv
, buildNpmPackage
, writeShellScriptBin
, swww
, bun
, dart-sass
, fd
, brightnessctl
, accountsservice
, webkitgtk_4_1
, ...
}:
let
  ags = inputs.ags.packages.${system}.default.override {
    extraPackages = [
      accountsservice
      webkitgtk_4_1
    ];

  };

  pname = "koshi";
  config = stdenv.mkDerivation {
    inherit pname;
    version = "1.7.6";
    src = buildNpmPackage {
      name = pname;
      src = ./.;
      dontBuild = true;
      npmDepsHash = "sha256-98C/eJ/Z8BO54TfBdklWpdffbrd0trvFG/TZB8si0Sk=";
      installPhase = ''
        mkdir $out
        cp -r * $out
      '';
    };

    patchPhase = ''
      cp -r node_modules $out
    '';

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
      cp -r assets $out
      cp -r style $out
      cp -r greeter $out
      cp -r widget $out
      cp -f main.js $out/config.js
      cp -f greeter.js $out/greeter.js
    '';
  };
in
{
  desktop = {
    inherit config;
    script = writeShellScriptBin pname ''
      export PATH=$PATH:${dart-sass}/bin
      export PATH=$PATH:${fd}/bin
      export PATH=$PATH:${brightnessctl}/bin
      export PATH=$PATH:${swww}/bin
      ${ags}/bin/ags -b ${pname} -c ${config}/config.js $@
    '';
  };
  greeter = {
    inherit config;
    script = writeShellScriptBin "greeter" ''
      export PATH=$PATH:${dart-sass}/bin
      export PATH=$PATH:${fd}/bin
      ${ags}/bin/ags -b ${pname} -c ${config}/greeter.js $@
    '';
  };
}

