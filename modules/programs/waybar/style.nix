{ location, user, ... }:
{
  home-manager.users.${user} = {
    programs.waybar = {
      style =
        ''
          * {
            border: none;
            font-family: "JetBrainsMono Nerd Font";
            font-weight: bold;
            font-size: 12px;
            min-height: 0px;
          }

          @import "${location}/modules/programs/waybar/themes/catppuccin.css";

          window#waybar {
            background: @bar-bg;
            border-bottom: 1px solid @main-bg;
            color: @main-color;
          }

          tooltip {
            background: @tool-bg;
            color: @main-color;
            border-radius: 8px;
            border-width: 1px;
            border-style: solid;
            border-color: @tool-border;
          }

          #workspaces {
            background-color: @main-bg;
            color: @main-color;
            border-radius: 30px 0px 0px 30px;
            margin: 6px 0px 6px 24px;
            padding: 4px 6px;
            border: solid 0px @main-color;
            font-weight: normal;
            font-style: normal;
          }

          #workspaces button {
            box-shadow: none;
            text-shadow: none;
            border-radius: 12px;
            padding: 0px 5px;
            margin: 0px 3px;
            color: @tool-bg;
            transition: all 0.1s ease-in-out;
          }

          #workspaces button.active {
            color: @main-color;
            background: @wb-bg;
            border-radius: 16px;
            min-width: 25px;
            padding-right: 6px;
            transition: all 0.2s ease-in-out;
          }

          #workspaces button:hover {
            color: @main-color;
            background: @wb-bg;
            padding-left: 8px;
            padding-right: 6px;
            transition: all 0.2s ease-in-out;
          }

          #window {
            color: @main-color;
            background: @main-bg;
            border-radius: 0px 30px 30px 0px;
            margin: 6px 0px 6px 0px;
            padding: 4px;
            padding-right: 20px;
            font-weight: normal;
            font-style: normal;
          }

          #custom-launcher {
            color: @launch-color;
            background-color: @main-bg;
            border-radius: 0px 24px 0px 0px;
            margin-top: 4px;
            padding: 0 20px 0 13px;
            font-size: 20px;
          }

          #custom-launcher button:hover {
            background-color: @power-hvr;
            color: transparent;
            border-radius: 8px;
            margin-right: -5px;
            margin-left: 10px;
          }

          #custom-notification {
            color: @main-color;
            background-color: @main-bg;
            border-radius: 0px 0px 0px 24px;
            margin: 0px 0px 4px 0px;
            padding: 0 13px 0 20px;
            font-size: 14px;
            font-weight: bold;
          }

          #cpu,
          #memory,
          #battery,
          #clock,
          #network,
          #bluetooth,
          #pulseaudio,
          #custom-updates,
          #custom-wallchange,
          #custom-wbar,
          #custom-l_end,
          #custom-r_end,
          #custom-sl_end,
          #custom-sr_end,
          #tray {
            color: @main-color;
            margin: 6px 0px;
            background-color: @main-bg;
            padding: 4px 6px;
            font-weight: normal;
            font-style: normal;
          }

          #custom-r_end {
            border-radius: 0px 30px 30px 0px;
            margin-right: 12px;
            padding-right: 4px;
          }

          #custom-l_end {
            border-radius: 30px 0px 0px 30px;
            margin-left: 12px;
            padding-left: 4px;
          }

          #custom-sr_end {
            border-radius: 0px;
            margin-right: 12px;
            padding-right: 4px;
          }

          #custom-sl_end {
            border-radius: 0px;
            margin-left: 12px;
            padding-left: 4px;
          }
        '';
    };
  };
}
