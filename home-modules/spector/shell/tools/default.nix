{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) getExe;
  inherit (builtins) readFile;
in
{
  home = {
    # make sure the scripts linked below in the session PATH
    # so that they can be referred to by name
    sessionPath = [ "${config.home.homeDirectory}/.local/tools" ];

    # link scripts to the local PATH
    file = {
      ".local/tools/rm-gpucache" = {
        # Remove GPU cache
        source = getExe (
          pkgs.writeShellApplication {
            name = "rm-gpucache";
            runtimeInputs = with pkgs; [ coreutils ];
            text = readFile ./rm-gpucache.sh;
          }
        );
      };
    };
  };
}
