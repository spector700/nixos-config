{ inputs, ... }:
{
  flake.aspects.dms.nixos =
    { config, lib, ... }:
    let
      inherit (lib) mkIf;
    in
    {
      systemd.user.services.niri-flake-polkit.enable = mkIf (config.programs.niri.enable or false) false;
    };

  flake.aspects.dms.homeManager =
    {
      lib,
      location,
      config,
      osConfig,
      self,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        mkMerge
        optionalAttrs
        splitString
        removePrefix
        ;
    in
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
      ];

      config = mkMerge [
        {
          home.packages = with pkgs; [
            dux-gop
            adw-gtk3
          ];

          xdg.configFile."dms".source =
            let
              configPath = removePrefix "${self.outPath}/" (toString ./_config);
            in
            config.lib.file.mkOutOfStoreSymlink "${location}/${configPath}";

          programs = {
            dank-material-shell = {
              enable = true;
              enableDynamicTheming = true;

              systemd = {
                enable = true;
                restartIfChanged = true;
              };
            };
            kitty.extraConfig = ''
              include dank-theme.conf
            '';
          };

          # Force Themeing
          gtk = {
            gtk3.extraCss = ''
              @import url("${config.xdg.configHome}/gtk-3.0/dank-colors.css");
            '';

            gtk4.extraCss = ''
              @import url("${config.xdg.configHome}/gtk-4.0/dank-colors.css");
            '';
          };
        }

        # NIRI
        (optionalAttrs (osConfig.programs.niri.enable or false) {
          programs.niri =
            let
              dms =
                cmd:
                [
                  "dms"
                  "ipc"
                  "call"
                ]
                ++ (splitString " " cmd);
            in
            {
              settings = {
                switch-events.lid-close.action.spawn = dms "lock lock";

                layer-rules = [

                  # Hide DMS notification popups from screencast captures
                  {
                    matches = [
                      { namespace = "^dms:notification-popup$"; }
                    ];
                    block-out-from = "screencast";
                  }
                ];

                binds = {
                  "Mod+Space".action.spawn = dms "spotlight toggle";
                  "Mod+V".action.spawn = dms "clipboard toggle";
                  "Ctrl+Alt+Delete".action.spawn = dms "session toggle";
                  "Mod+Escape".action.spawn = dms "lock lock";
                  "Mod+Comma".action.spawn = dms "settings toggle";
                  # "Print".action.spawn = dms "niri screenshot";

                  "XF86AudioPlay" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "playPause"
                    ];
                  };

                  "XF86AudioPause" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "playPause"
                    ];
                  };

                  "XF86AudioNext" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "next"
                    ];
                  };

                  "XF86AudioPrev" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "previous"
                    ];
                  };

                  "XF86AudioStop" = {
                    allow-when-locked = true;
                    action.spawn = [
                      "dms"
                      "ipc"
                      "call"
                      "mpris"
                      "stop"
                    ];
                  };
                };
              };
            };
        })

        # HYPRLAND
        (optionalAttrs (osConfig.programs.hyprland.enable or false) {
          wayland.windowManager.hyprland = {
            extraConfig = ''
              require("dms.colors")
              require("dms.layout")
              require("dms.windowrules")
            '';

            extraLuaFiles."nix/dms-binds" = ''
              hl.bind("SUPER + comma", hl.dsp.exec_cmd("dms ipc call settings toggle"))
              hl.bind("SUPER + escape", hl.dsp.exec_cmd("dms ipc call lock lock"))
              hl.bind("SUPER + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
              hl.bind("SUPER + space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
            '';

          };
        })
      ];
    };
}
