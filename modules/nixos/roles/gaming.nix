# Gaming
#
# Do not forget to enable Steam capatability for all title in the settings menu
#
{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption getExe;

  cfg = config.modules.roles.gaming;
  user = config.modules.os.mainUser;
in
{
  options.modules.roles.gaming = {
    enable = mkEnableOption "Enable packages required for the device to be gaming-ready";
  };

  config = mkIf cfg.enable {
    boot = {
      # For division 2
      kernelParams = [ "split_lock_mitigate=0" ];
      kernel.sysctl = {
        # default on some gaming (SteamOS) and desktop (Fedora) distributions
        # might help with gaming performance
        "vm.max_map_count" = 2147483642;
        "fs.file-max" = 524288;
      };
    };

    # consoleExperience.enable = true;

    # Xbox controller support
    hardware.xone.enable = true;

    programs = {
      steam = {
        enable = true;
        # Open ports in the firewall for Steam Remote Play
        remotePlay.openFirewall = false;
        extest.enable = true; # For wayland
        extraCompatPackages = [
          inputs.chaotic.packages.${pkgs.system}.proton-cachyos
        ];
      };

      # Optimise Linux system performance on demand
      # https://github.com/FeralInteractive/GameMode
      # https://wiki.archlinux.org/title/Gamemode
      #
      # Usage:
      #   1. For games/launchers which integrate GameMode support:
      #      https://github.com/FeralInteractive/GameMode#apps-with-gamemode-integration
      #      simply running the game will automatically activate GameMode.
      #   2. For others, launching the game through gamemoderun: `gamemoderun ./game`
      #   3. For steam: `gamemoderun %command%`
      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 15;
          };
          custom = {
            start = "${getExe pkgs.libnotify} 'GameMode started'";
            end = "${getExe pkgs.libnotify} 'GameMode ended'";
          };
        };
      };
    };

    # required since gamemode 1.8 to change CPU governor
    users.users.${user}.extraGroups = [ "gamemode" ];

    services.udev = {
      packages = with pkgs; [
        game-devices-udev-rules
        # Dualsense touchpad https://wiki.archlinux.org/title/Gamepad#Motion_controls_taking_over_joypad_controls_and/or_causing_unintended_input_with_joypad_controls
        (writeTextFile {
          name = "51-disable-Dualshock-motion-and-trackpad.rules";
          text = ''
            SUBSYSTEM=="input", ATTRS{name}=="*Controller Motion Sensors", RUN+="${pkgs.coreutils}/bin/rm %E{DEVNAME}", ENV{ID_INPUT_JOYSTICK}=""
            SUBSYSTEM=="input", ATTRS{name}=="*Controller Touchpad", RUN+="${pkgs.coreutils}/bin/rm %E{DEVNAME}", ENV{ID_INPUT_JOYSTICK}=""
          '';
          destination = "/etc/udev/rules.d/51-disable-Dualshock-motion-and-trackpad.rules";
        })
      ];

      extraRules = ''KERNEL=="vhba_ctl", MODE="0660", OWNER="root", GROUP="cdrom"'';
    };
  };
}
