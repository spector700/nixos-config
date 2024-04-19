# kitty terminal
{
  programs = {
    kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
      };
      shellIntegration.enableZshIntegration = true;

      theme = "Catppuccin-Mocha";
      settings = {
        confirm_os_window_close = 0;
        placement_strategy = "center";

        enable_audio_bell = false;
      };
      keybindings = {
        "ctrl+tab" = "send_text all \\x1b[9;5u"; # <C-Tab>
        "ctrl+shift+tab" = "send_text all \\x1b[9;6u"; # <C-S-Tab>
      };
    };
  };
}
