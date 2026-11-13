_: {
  flake.aspects.davinci-resolve.homeManager =
    { pkgs, ... }:

    let
      # Fix the error with: 'Could not find the Qt platform plugin "wayland"'
      davinci-resolve-qt-workaround =
        bin: pkg:
        pkgs.symlinkJoin {
          name = bin;
          paths = [ pkg ];
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = # sh
            ''
              wrapProgram $out/bin/${bin} \
                --set QT_QPA_PLATFORM 'xcb'
            '';
          meta.mainProgram = bin;
        };
    in
    {

      home.packages = with pkgs; [
        # (davinci-resolve-qt-workaround "davinci-resolve" davinci-resolve)
        davinci-resolve
      ];
    };
}
