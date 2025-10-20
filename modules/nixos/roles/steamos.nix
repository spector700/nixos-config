{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.consoleExperience;
  defaultSession = "Hyprland";
  username = config.modules.os.mainUser;
in
{
  options.consoleExperience = {
    enable = lib.mkEnableOption "Enable Steam Console Experience in NixOS";
    enableHDR = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    enableVRR = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    enableDesktopShortcut = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      DESKTOP_SESSION = "${defaultSession}";
    };
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "jupiter-biosupdate" ''
        #!/bin/bash
        exit 0;
      '')
      (writeShellScriptBin "steamos-select-branch" ''
        #!/bin/bash
        echo "Not applicable for this OS"
      '')
      (writeShellScriptBin "steamos-update" ''
        #!/bin/bash
        exit 7;
      '')
      (writeShellScriptBin "switch-to-steamos" ''
        #!/bin/bash
        set -euo pipefail

        mkdir -p ~/.local/state
        echo "steam" > ~/.local/state/steamos-session-select

        # Shutdown Steam if running
        if pgrep -x steam >/dev/null; then
            echo "Shutting down Steam..."
            steam -shutdown
            while pgrep -x steam >/dev/null; do
                sleep 1
            done
            echo "Steam closed."
        fi

        loginctl terminate-user "${username}"
        # hyprctl dispatch exit
      '')
      (writeShellScriptBin "switch-to-desktop" ''
        #!/bin/bash
        set -euo pipefail

        # Mark that we want to boot into desktop mode
        mkdir -p ~/.local/state
        echo "${defaultSession}" > ~/.local/state/steamos-session-select

        # Shutdown Steam
        if pgrep -x steam >/dev/null; then
            steam -shutdown
            while pgrep -x steam >/dev/null; do
                sleep 1
            done
        fi

        # Exit gamescope session
        killall -TERM gamescope || true
      '')
      (writeShellScriptBin "restart-displaymanager" ''
        #!/bin/bash
        sudo systemctl restart display-manager
      '')
      (writeShellScriptBin "steamos-session-select" ''
        #!/bin/bash
        steam -shutdown
      '')
      (writeShellScriptBin "steamos-cleanup" ''
        #!/bin/bash
        # Remove autologin configuration when switching to desktop
        rm $XDG_RUNTIME_DIR/switch-to-desktop
        rm $XDG_RUNTIME_DIR/switch-to-steam
      '')
      (writeShellScriptBin "get-screen-device-name" ''
        #!/bin/bash
        echo $(${pkgs.edid-decode}/bin/edid-decode /sys/class/drm/card1-HDMI-A-1/edid | grep "Display Product Name" | cut -d"'" -f2)
      '')

      # (writeShellScriptBin "get-screen-refresh-rate" ''
      #   #!/bin/bash
      #   device_name=$(get-screen-device-name)
      #   if [[ "$device_name" == "LG TV SSCR2" ]]; then
      #     echo "120"
      #   else
      #     refresh=$(${pkgs.edid-decode}/bin/edid-decode /sys/class/drm/card1-HDMI-A-1/edid 2>/dev/null | grep "Maximum Refresh Rate" | cut -d"'" -f2 | awk '{print $4}')
      #     if [[ -z "$refresh" || "$refresh" -eq 0 ]]; then
      #       echo "60"
      #     else
      #       echo "$refresh"
      #     fi
      #   fi
      # '')
      (writeShellScriptBin "gamescope-session" ''
         #!/bin/bash

         # Mark session preference
         mkdir -p ~/.local/state
         # >~/.local/state/steamos-session-select echo "${defaultSession}"
         echo "steam" > ~/.local/state/steamos-session-select

        ${lib.optionalString cfg.enableHDR "export ENABLE_HDR_WSI=1"}
         ${lib.optionalString cfg.enableVRR "export ENABLE_VRR=1"}

         width=1920
         height=1080
         refresh_rate=100

         exec gamescope \
           --steam \
           -r $refresh_rate \
           -w $width -h $height \
           -W $width -H $height \
           -O DP-2 \
           --rt \
           --immediate-flips \
           --force-grab-cursor \
          ${lib.optionalString cfg.enableHDR "--hdr-enabled --hdr-itm-enable"} \
          ${lib.optionalString cfg.enableVRR "--adaptive-sync"} \
           -- steam -steampal -steamdeck -gamepadui -pipewire-dmabuf

           sleep 5
           systemctl --user start --now sunshine
      '')
    ];
    security.sudo.extraRules = [
      {
        users = [ username ];
        commands = [
          # Make it so we don't need to elevate to switch to gaming mode
          {
            command = "/run/current-system/sw/bin/restart-displaymanager";
            options = [
              "SETENV"
              "NOPASSWD"
            ];
          }
        ];
      }
    ];

    # Boot to SteamOS when connected to my LG TV
    systemd.services.set-session = {
      wantedBy = [ "multi-user.target" ];
      before = [ "display-manager.service" ];
      enable = true;
      serviceConfig = {
        User = "root";
        Group = "root";
      };
      path = [ "/run/current-system/sw" ];
      script = ''
        #!/bin/sh
        displayProductName=$(${pkgs.edid-decode}/bin/edid-decode /sys/class/drm/card1-HDMI-A-1/edid | grep "Display Product Name" | cut -d"'" -f2)
        if [[ "$displayProductName" == *"LG TV"* ]]; then
          # echo -e "\n[Autologin]\nUser=${username}\nSession=steam\nEnable=true" > /etc/sddm.conf.d/20-defaultsession.conf
          mkdir -p ~/.local/state
          >~/.local/state/steamos-session-select echo "steam"
        fi
      '';
    };

    services.displayManager.sessionPackages = lib.mkIf cfg.enable [
      (
        # Override the steam.desktop file to use the gamescope-session script
        (pkgs.writeTextDir "share/wayland-sessions/steam.desktop" ''
          [Desktop Entry]
          Name=SteamOS
          Comment=Steam Big Picture in Gamescope
          Exec=gamescope-session
          Type=Application
        '').overrideAttrs
          (_: {
            passthru.providedSessions = [ "steam" ];
          })
      )
    ];
    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        home.file = {
          "${config.xdg.configHome}/icons/steam-gaming-return.png" = {
            source = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/unlbslk/arch-deckify/refs/heads/main/icons/steam-gaming-return.png";
              sha256 = "sha256-Lc5y6jzhrtQAicXnyrr+LrsE7Is/Xbg5UeO0Blisz8I=";
            };
          };

          "${config.xdg.configHome}/autostart/steamos-cleanup.desktop" = {
            text = ''
              [Desktop Entry]
              Name=SteamOS Cleanup
              Exec=steamos-cleanup
              Terminal=false
              Type=Application
            '';
          };
        }
        // lib.optionalAttrs cfg.enableDesktopShortcut {
          "Desktop/Return_to_Gaming_Mode.desktop" = {
            text = ''
              [Desktop Entry]
              Name=Gaming Mode
              Exec=switch-to-steamos
              Icon=${config.xdg.configHome}/icons/steam-gaming-return.png
              Terminal=false
              Type=Application
              StartupNotify=false
            '';
            executable = true;
          };
        };

        xdg.desktopEntries.gamingmode = {
          name = "Switch to Gaming Mode";
          genericName = "Switch to Gaming Mode";
          exec = "switch-to-steamos";
          terminal = false;
          categories = [
            "Application"
            "Game"
          ];
          icon = "${config.xdg.configHome}/icons/steam-gaming-return.png";
        };
      };
  };
}
