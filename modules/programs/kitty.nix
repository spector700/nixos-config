{ pkgs, ... }:

{
  programs = {
    kitty = {
      enable = true;
      font = {
        # Font - Laptop has size manually changed at home.nix
        name = "JetBrainsMono Nerd Font";
        #size = 8;
      };
      shellIntegration.enableZshIntegration = true;

      theme = "Catppuccin-Mocha";
      settings = {
        confirm_os_window_close = 0;
        placement_strategy = "center";

        enable_audio_bell = false;
      };
    };
  };
}
