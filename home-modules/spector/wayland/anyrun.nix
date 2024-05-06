{ inputs, pkgs, ... }:
{
  imports = [ inputs.anyrun.homeManagerModules.default ];

  programs.anyrun = {
    enable = true;
    config = {
      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        applications
        rink
        randr
        shell
        symbols
        stdin
      ];
      width.fraction = 0.3;
      y.absolute = 300;
      hidePluginInfo = true;
      closeOnClick = true;
    };
    extraConfigFiles = {
      "symbols.ron".text = ''
        Config(
          prefix: ":e",
        )
      '';
    };
    extraCss = ''
      * {
        transition: 200ms ease;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 0.875rem;
      }

      #window,
      #match,
      #entry,
      #plugin,
      #main {
        background: transparent;
      }

      #match:selected {
        background: rgba(203, 166, 247, 0.7);
      }

      #match {
        padding: 3px;
        border-radius: 5px;
      }

      #entry, #plugin:hover {
        border-radius: 16px;
      }

      box#main {
        background: rgba(30, 30, 46, 0.7);
        border: 1px solid #1c272b;
        border-radius: 24px;
        padding: 8px;
      }
    '';
  };
}
