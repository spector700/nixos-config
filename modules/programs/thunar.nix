{ pkgs, ... }:

{

  programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        volman
        archive-plugin
        media-tags-plugin
      ];
    };

  services.tumbler.enable = true;

}
