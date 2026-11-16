_: {
  flake.aspects.kitty.homeManager = { osConfig, ... }: {
    programs = {
      kitty = {
        enable = true;
        font = {
          name = osConfig.modules.os.font.name;
        };
        shellIntegration.enableZshIntegration = true;

        settings = {
          confirm_os_window_close = 0;
          placement_strategy = "center";
          remember_window_size = false;

          enable_audio_bell = false;
        };
        keybindings = {
          "ctrl+tab" = "send_text all \\x1b[9;5u"; # <C-Tab>
          "ctrl+shift+tab" = "send_text all \\x1b[9;6u"; # <C-S-Tab>
        };
      };
    };
  };
}
