#
# Bar
#

{ pkgs, host, user, ... }:

let
  modules = {

    "hyprland/workspaces" = {
      "disable-scroll" = true;
      "all-outputs" = true;
      "on-click" = "activate";
      "format" = "{icon}";
      "format-icons" = {
        "urgent" = "";
        "active" = "";
        "default" = "󰧞";
        "sort-by-number" = true;
      };
    };

    "hyprland/window" = {
      format = "  {}";
      max-length = 200;
      separate-outputs = true;
      rewrite = {
        "~/(.*)" = "";
        "(.*) - Brave" = "󰈹";
        "(.*) — Mozilla Firefox" = "󰈹";
        "(.*) - Visual Studio Code" = " 󰨞";
        "(.*)Visual Studio Code" = "Code 󰨞";
        "(.*) - Thunar" = " 󰉋";
        "(.*)Spotify" = "Spotify 󰓇";
        "(.*)Steam" = "Steam 󰓓";
        "(.*)WebCord -" = "󰙯";
      };
    };

    clock = {
      format = "{: %H:%M  󰃭 %a %d}";
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
    };

    cpu = {
      interval = 2;
      format = "󰻠 {usage}%";
      format-alt = "󰻠 {avg_frequency} GHz";
    };

    memory = {
      interval = 2;
      format = "󰾆 {used} GB";
      format-alt = "󰾆 {used}/{total} GiB";
    };

    network = {
      # interface = "wlp2*"; # (Optional) To force the use of this interface
      format-wifi = "󰤨";
      format-ethernet = "";
      tooltip-format = "{essid}";
      format-linked = "󰈀 {ifname} (No IP)";
      format-disconnected = "󰤭";
      on-click = "nm-connection-editor";
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

    "custom/launcher" = {
      format = "";
      on-click = "anyrun";
    };

    pulseaudio = {
      format = "{icon} {volume}";
      format-muted = "婢";
      on-click = "pavucontrol -t 3";
      on-click-middle = "~/.config/waybar/scripts/volumecontrol.sh -o m";
      on-scroll-up = "~/.config/waybar/scripts/volumecontrol.sh -o i";
      on-scroll-down = "~/.config/waybar/scripts/volumecontrol.sh -o d";
      tooltip-format = "{icon} {desc}";
      scroll-step = 5;
      format-icons = {
        headphone = "";
        hands-free = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = [ "" "" "" ];
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
      format = "󰮯 {}";
      exec = "~/.config/hypr/scripts/systemupdate.sh";
      on-click = "~/.config/hypr/scripts/systemupdate.sh up";
      interval = 86400;
      tooltip = true;
    };

    "custom/notification" = {
      tooltip = false;
      format = "{icon}";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "sleep 0.1 && swaync-client -t -sw";
      escape = true;
    };

    tray = {
      icon-size = 16;
      spacing = 5;
    };

    "custom/wallchange" = {
      "format" = "{}";
      "exec" = "echo ; echo 󰆊 switch wallpaper";
      "on-click" = "~/.config/swww/swwwallpaper.sh -n 4";
      "on-click-right" = "~/.config/swww/swwwallpaper.sh -p 4";
      "interval" = 86400; # once every day
      "tooltip" = true;
    };

    # modules for padding 

    "custom/l_end" = {
      format = " ";
      interval = "once";
      tooltip = false;
    };

    "custom/r_end" = {
      format = " ";
      interval = "once";
      tooltip = false;
    };

    "custom/sl_end" = {
      format = " ";
      interval = "once";
      tooltip = false;
    };

    "custom/sr_end" = {
      format = " ";
      interval = "once";
      tooltip = false;
    };

    backlight = {
      device = "intel_backlight";
      format = "{percent}% <span font='11'>{icon}</span>";
      format-icons = [ "" "" ];
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
      format-icons = [ "" "" "" "" "" ];
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
  };
  waybar_style = import ./style.nix;

in
{
  imports = [ ./scripts ];

  nixpkgs.overlays = [
    (final: prev: {
      waybar = prev.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      });
    })
  ];

  home-manager.users.${user} = {
    programs.waybar = {
      enable = true;

      style = waybar_style;

      settings = with host; {
        Main = modules // {
          layer = "top";
          position = "top";
          height = 37;
          gtk-layer-shell = true;
          output = [
            "${mainMonitor}"
          ];

          modules-left = [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "custom/l_end" "clock" "custom/r_end" ];
          modules-right =
            if hostName == "Alfhiem-Nix" then
              [ "custom/l_end" "cpu" "memory" "custom/r_end" "custom/l_end" "network" "bluetooth" "pulseaudio" "pulseaudio#microphone" "custom/updates" "custom/r_end" "custom/l_end" "tray" "custom/r_end" "custom/l_end" "custom/wallchange" "custom/wbar" "custom/r_end" "custom/notification" ]
            else
              [ "cpu" "memory" "custom/pad" "battery" "custom/pad" "backlight" "custom/pad" "pulseaudio" "custom/pad" "clock" "tray" ];
        };

        Sec = modules // (if hostName == "Alfhiem-Nix" || hostName == "work" then {
          layer = "top";
          position = "top";
          height = 16;
          output =
            if hostName == "Alfhiem-Nix" then [
              "${secondMonitor}"
            ] else [
              "${secondMonitor}"
              "${thirdMonitor}"
            ];
          modules-left = [ "custom/launcher" "hyprland/workspaces" "hyprland/window" ];
          modules-center = [ "custom/l_end" "clock" "custom/r_end" ];
          modules-right =
            if hostName == "Alfhiem-Nix" then
              [ "custom/l_end" "cpu" "memory" "custom/r_end" "custom/l_end" "tray" "custom/r_end" "custom/l_end" "network" "bluetooth" "pulseaudio" "pulseaudio#microphone" "custom/r_end" "custom/notification" ]
            else
              [ "cpu" "memory" "custom/pad" "battery" "custom/pad" "backlight" "custom/pad" "pulseaudio" "custom/pad" "clock" ];

        } else { });
      };
    };
  };
}
