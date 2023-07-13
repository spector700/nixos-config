#
# Bar
#

{ config, lib, pkgs, host, user, ...}:

{
  imports = [ ./scripts ];

  # nixpkgs.overlays = [                                      # Waybar needs to be compiled with the experimental flag for wlr/workspaces to work (for now done with hyprland.nix)
  #   (self: super: {
  #     waybar = super.waybar.overrideAttrs (oldAttrs: {
  #       mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
  #       patchPhase = ''
  #         substituteInPlace src/modules/wlr/workspace_manager.cpp --replace "zext_workspace_handle_v1_activate(workspace_handle_);" "const std::string command = \"hyprctl dispatch workspace \" + name_; system(command.c_str());"
  #       '';
  #     });
  #   })
  # ];

  home-manager.users.${user} = {                           # Home-manager waybar config
    programs.waybar = {
      enable = true;
      systemd ={
        enable = true;
        target = "sway-session.target";                     # Needed for waybar to start automatically
      };

      style = builtins.readFile ./style.css;

      settings = with host; {
        Main = {
          layer = "top";
          position = "top";
          height = 31;
          gtk-layer-shell = true;
          output = [
            "${mainMonitor}"
          ];


          modules-left = with config;
            if programs.hyprland.enable == true then
              [ "custom/padd" "custom/l_end" "wlr/workspaces" "hyprland/window" "custom/r_end" "custom/padd" ]
            else if programs.sway.enable == true then
              [ "sway/workspaces" "sway/window" "sway/mode" ]
            else [];

          modules-center = [ "custom/padd" "custom/l_end" "clock" "custom/r_end" "custom/padd" ];

          modules-right =
            if hostName == "Alfhiem-Nix" then
              [ "custom/padd" "custom/l_end" "cpu" "memory" "custom/r_end" "custom/l_end" "network""bluetooth" "pulseaudio" "pulseaudio#microphone" "custom/updates" "custom/r_end" "custom/l_end" "tray" "custom/r_end" "custom/l_end" "custom/wallchange" "custom/mode" "custom/wbar" "custom/cliphist" "custom/power" "custom/r_end" "custom/padd" ]
            else
              [ "cpu" "memory" "custom/pad" "battery" "custom/pad" "backlight" "custom/pad" "pulseaudio" "custom/pad" "clock" "tray" ];

            "wlr/workspaces" = {
                  "disable-scroll" = true;
                  "all-outputs" = true;
                  "on-click" = "activate";
                  "persistent_workspaces" = { 
                      "1" = [];
                      "2" = [];
                      "3" = [];
                      "4" = [];
                      "5" = [];
                      "6" = [];
                      "7" = [];
                      "8" = [];
                      "9" = [];
                      "10" = [];
                  };
              };

          "hyprland/window" =  {
              "format" = "  {}";
              "separate-outputs" = true;
              "rewrite" = {
                  "nick@Alfhiem-Nix =(.*)" = " ";
                  "(.*) — Brave" = " 󰈹";
                  "(.*)Brave" = "Brave 󰈹";
                  "(.*) - Visual Studio Code" = " 󰨞";
                  "(.*)Visual Studio Code" = "Code 󰨞";
                  "(.*) — Thunar" = " 󰉋";
                  "(.*)Spotify" = "Spotify 󰓇";
                  "(.*)Steam" = "Steam 󰓓";
              };
          };

          clock = {
              format = "{: %H:%M %p 󰃭 %a %d}";
              format-alt = "{:󰥔 %I:%M  %b %Y}";
              tooltip-format = "<tt><big>{calendar}</big></tt>";
          };


          "cpu" = {
              "interval" = 2;
              "format" = "󰍛 {usage}%";
              "format-alt" = "{icon0}{icon1}{icon2}{icon3}";
              "format-icons" = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
          };

          "memory" = {
              "interval" = 2;
              "format" = "󰾆 {percentage}%";
              "format-alt" = "󰾅 {used}GB";
              "max-length" = 10;
              "tooltip" = true;
              "tooltip-format" = " {used:0.1f}GB/{total:0.1f}GB";
          };

          network = {
              # interface = "wlp2*"; # (Optional) To force the use of this interface
              format-wifi = "󰤨 {essid}";
              format-ethernet = "󰈀 ";
              tooltip-format = "󰈀 {ipaddr}  {bandwidthUpBytes}  {bandwidthDownBytes}";
              format-linked = "󰈀 {ifname} (No IP)";
              format-disconnected = " Disconnected";
              format-alt = "󰤨 {signalStrength}%";
              interval = 5;
          };

          bluetooth = {
              format = "";
              format-disabled = ""; # an empty format will hide the module
              format-connected = " {num_connections}";
              tooltip-format = " {device_alias}";
              tooltip-format-connected = "{device_enumerate}";
              tooltip-format-enumerate-connected = " {device_alias}";
          };

          pulseaudio = {
              format = "{icon} {volume}";
              format-muted = "婢";
              on-click = "pavucontrol -t 3";
              on-click-middle = "~/.config/waybar/scripts/volumecontrol.sh -o m";
              on-scroll-up = "~/.config/waybar/scripts/volumecontrol.sh -o i";
              on-scroll-down = "~/.config/waybar/scripts/volumecontrol.sh -o d";
              tooltip-format = "{icon} {desc} // {volume}%";
              scroll-step = 5;
              format-icons = {
                  headphone = "";
                  hands-free = "";
                  headset = "";
                  phone = "";
                  portable = "";
                  car = "";
                  default = ["" "" ""];
              };
          };

          "pulseaudio#microphone" = {
              format = "{format_source}";
              format-source = "";
              format-source-muted = "";
              on-click = "pavucontrol -t 4";
              on-click-middle = "~/.config/waybar/scripts/volumecontrol.sh -i m";
              on-scroll-up = "~/.config/waybar/scripts/volumecontrol.sh -i i";
              on-scroll-down = "~/.config/waybar/scripts/volumecontrol.sh -i d";
              tooltip-format = "{format_source} {source_desc} // {source_volume}%";
              scroll-step = 5;
          };

          "custom/updates" = {
              "format" = "󰮯 {}";
              "exec" = "~/.config/hypr/scripts/systemupdate.sh";
              "on-click" = "~/.config/hypr/scripts/systemupdate.sh up";
              "interval" = 86400;
              "tooltip" = true;
          };

          tray = {
              "icon-size" = 18;
              "spacing" = 5;
          };

          "custom/wallchange" = {
              "format" = "{}";
              "exec" = "echo ; echo 󰆊 switch wallpaper";
              "on-click" = "~/.config/swww/swwwallpaper.sh -n 4";
              "on-click-right" = "~/.config/swww/swwwallpaper.sh -p 4";
              "interval" = 86400;  # once every day
              "tooltip" = true;
          };


          "custom/mode" = {
              "format" = "{}";
              "exec" = "echo ; echo 󰟡 switch mode";
              "on-click" = "~/.config/hypr/scripts/themeswitch.sh -n";
              "on-click-right" = "~/.config/hypr/scripts/themeswitch.sh -p";
              "on-click-middle" = "sleep 0.1 && ~/.config/hypr/scripts/themeselect.sh";
              "interval" = 86400;  # once every day
              "tooltip" = true;
          };

          "custom/cliphist" = {
              "format" = "{}";
              "exec" = "echo ; echo 󰅇 clipboard history";
              "on-click" = "sleep 0.1 && ~/.config/hypr/scripts/cliphist.sh c 4";
              #"on-click-right" = "sleep 0.1 && ~/.config/hypr/scripts/cliphist.sh d";
              "on-click-middle" = "sleep 0.1 && ~/.config/hypr/scripts/cliphist.sh w 4";
              "interval" = 86400;  # once every day
              "tooltip" = true;
          };

          "custom/power" = {
              "format" = "{}";
              "exec" = "echo ; echo  logout";
              "on-click" = "wlogout -b 2 -c 0 -r 0 -L 930 -R 930 -T 300 -B 300 --protocol layer-shell";
              "interval" = 86400;  # once every day
              "tooltip" = true;
          };

          "wlr/taskbar" = {
            "format" = "{icon}";
            "icon-size" = 18;
            "icon-theme" = "Papirus-Dark";
                "spacing" = 0;
            "tooltip-format" = "{title}";
            "on-click" = "activate";
            "on-click-middle" = "close";
            "ignore-list" = [
              "kitty"
            ];
            #"app_ids-mapping" = {
            #  "firefoxdeveloperedition" "firefox-developer-edition"
          # };
          };

          "mpris" = {
              "format" = "{player_icon} {dynamic}";
              "format-paused" = "{status_icon} <i>{dynamic}</i>";
              "player-icons" = { 
                  "default" = "▶";
                  "mpv" = "🎵";
              };
              "status-icons" = {
                  "paused" = "⏸";
              };
              "ignored-players" = ["brave"];
          };

        # modules for padding 

          "custom/l_end" = {
              "format" = " ";
              "interval"  = "once";
              "tooltip" = false;
          };

          "custom/r_end" = {
              "format" = " ";
              "interval"  = "once";
              "tooltip" = false;
          };

          "custom/sl_end" = {
              "format" = " ";
              "interval"  = "once";
              "tooltip" = false;
          };

          "custom/sr_end" = {
              "format" = " ";
              "interval"  = "once";
              "tooltip" = false;
          };

          "custom/padd" = {
              "format" = "  ";
              "interval"  = "once";
              "tooltip" = false;
          };
        };
        Sec = if hostName == "Alfhiem-Nix" || hostName == "work" then {
          layer = "top";
          position = "top";
          height = 16;
          output = if hostName == "Alfhiem-Nix" then [
            "${secondMonitor}"
          ] else [
            "${secondMonitor}"
            "${thirdMonitor}"
          ];
          modules-left = [ "custom/menu" "wlr/workspaces" ];

          modules-right =
            if hostName == "desktop" then
              [ "custom/ds4" "custom/hid" "custom/pad" "pulseaudio" "custom/sink" "custom/pad" "clock"]
            else
              [ "cpu" "memory" "custom/pad" "battery" "custom/pad" "backlight" "custom/pad" "pulseaudio" "custom/pad" "clock" ];

          "wlr/workspaces" = {
            format = "<span font='11'>{name}</span>";
            #format = "<span font='12'>{icon}</span>";
            #format-icons = {
            #  "1"="";
            #  "2"="";
            #  "3"="";
            #  "4"="";
            #  "5"="";
            #  "6"="";
            #  "7"="";
            #  "8"="";
            #  "9"="";
            #  "10"="";
            #};
            active-only = false;
            on-click = "activate";
            #on-scroll-up = "hyprctl dispatch workspace e+1";
            #on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          clock = {
            format = "{:%b %d %H:%M}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            #format-alt = "{:%A, %B %d, %Y} ";
          };

          backlight = {
            device = "intel_backlight";
            format= "{percent}% <span font='11'>{icon}</span>";
            format-icons = ["" ""];
            on-scroll-down = "${pkgs.light}/bin/light -U 5";
            on-scroll-up = "${pkgs.light}/bin/light -A 5";
          };
          battery = {
            interval = 60;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% <span font='11'>{icon}</span>";
            format-charging = "{capacity}% <span font='11'></span>";
            format-icons = ["" "" "" "" ""];
            max-length = 25;
          };
          "custom/hid" = {
            format = "{}";
            exec = "$HOME/.config/waybar/scripts/hid.sh";
            interval = 60;
          };
          "custom/ds4" = {
            format = "{}";
            exec = "$HOME/.config/waybar/scripts/ds4.sh";
            interval = 60;
          };
        } else {};
      };
    };
  };
}
