

{ pkgs, ...}:

{
  home.packages = with pkgs; [
      swaync
    ];

}
