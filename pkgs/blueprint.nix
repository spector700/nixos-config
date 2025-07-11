{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper, # from pkgs: makeWrapper
  nodejs,
  yarn,
  bash,
  unzip,
  zip,
  curl,
  php,
  git,
  ncurses,
}:
stdenv.mkDerivation rec {
  pname = "blueprint";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "BlueprintFramework";
    repo = "framework";
    rev = "main";
    sha256 = "sha256-S5Bwyvouce/90IOMNxNx2zlQ6ePkMkzkWsLyrhko2y4="; # updated via nix-prefetch-url
  };

  nativeBuildInputs = [ makeWrapper ];

  # Everything your script will invoke at runtime:
  buildInputs = [
    nodejs
    yarn
    bash
    unzip
    zip
    curl
    php
    git
    ncurses
  ];

  installPhase = ''
      # 1. Copy the full repo so scripts/ and helpers/ stay in place
      mkdir -p $out/libexec/blueprint
      cp -r $src/* $out/libexec/blueprint

      # 2. Fix the she‑bang of the *real* script
      substituteInPlace $out/libexec/blueprint/blueprint.sh \
        --replace-warn '^#!/usr/bin/env bash' "#!${bash}/bin/bash"
      chmod +x $out/libexec/blueprint/blueprint.sh

      # 3. Write a minimal wrapper as the public cli
      mkdir -p $out/bin
      cat > $out/bin/blueprint <<'WRAP'
    #!/usr/bin/env bash
    # add the runtime tools to PATH
    export PATH="@PATH@:$PATH"
    # tell blueprint where its repo lives
    export FOLDER="@REPO@"
    export BLUEPRINT__SOURCEFOLDER="@REPO@"
    # run from inside the repo so all `source scripts/...` succeeds
    cd "$FOLDER" || exit 1
    exec "$FOLDER/blueprint.sh" "$@"
    WRAP
      substituteInPlace $out/bin/blueprint \
        --subst-var-by PATH "${lib.makeBinPath buildInputs}" \
        --subst-var-by REPO "$out/libexec/blueprint"
      chmod +x $out/bin/blueprint
  '';

  passthru = {
    updateScript = {
      command = "nix-update blueprint --version=unstable";
    };
  };

  meta = with lib; {
    description = "A framework for Pterodactyl panel extensions";
    homepage = "https://github.com/BlueprintFramework/framework";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
