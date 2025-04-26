{
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = osConfig.modules.roles.video;

  # fix the error with: 'Could not find the Qt platform plugin "wayland"'
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
  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      # plugins = with pkgs.stable.obs-studio-plugins; [
      #   obs-composite-blur
      #   obs-backgroundremoval
      #   obs-pipewire-audio-capture
      # ];
    };

    home.packages = with pkgs; [
      (davinci-resolve-qt-workaround "davinci-resolve" davinci-resolve)
    ];
  };
}
