{ pkgs, ... }:
# Lockscreen
{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      image = "$HOME/.config/wallpaper";
      effect-blur = "10x2";
      fade-in = 0.2;
      clock = true;
      font-size = "24";
      indicator-idle-visible = true;
      indicator-radius = 200;
      indicator-thickness = 20;

      key-hl-color = "eb6f92";
      separator-color = "00000000";

      inside-color = "00000033";
      inside-clear-color = "ffffff00";
      inside-ver-color = "ffffff00";
      inside-wrong-color = "1f1d2e";

      line-color = "00000000";
      line-clear-color = "ffffffFF";
      line-ver-color = "ffffffFF";
      line-wrong-color = "ffffffFF";

      ring-color = "ffffff";
      ring-clear-color = "ffffff";
      ring-caps-lock-color = "ffffff";
      ring-ver-color = "ffffff";
      ring-wrong-color = "ffffff";

      text-color = "ffffff";
      text-ver-color = "ffffff";
      text-wrong-color = "ffffff";
      text-caps-lock-color = "ffffff";
      show-failed-attempts = true;
    };
  };
}
