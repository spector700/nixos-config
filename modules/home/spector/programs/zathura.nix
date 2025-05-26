# PDF Viewer
{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.programs.zathura;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.modules.programs.zathura = {
    enable = mkEnableOption "Enable zathura pdf viewer";
  };

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      options = {
        selection-notification = true;

        selection-clipboard = "clipboard";
        adjust-open = "best-fit";
        pages-per-row = "1";
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        scroll-step = "100";
        zoom-min = "10";
      };
    };
  };
}
