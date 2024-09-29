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
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.programs.gaming;
  user = config.modules.os.mainUser;
in
{
  options.modules.programs.gaming = {
    enable = mkEnableOption "Enable packages required for the device to be gaming-ready";
  };

  config = mkIf cfg.enable {
    home-manager.users.${user}.home.packages = with pkgs; [
      inputs.nix-citizen.packages.${system}.star-citizen
      lutris
      prismlauncher # Minecraft
      bottles
    ];

    boot.kernel.sysctl = {
      # default on some gaming (SteamOS) and desktop (Fedora) distributions
      # might help with gaming performance
      "vm.max_map_count" = 2147483642;
      "fs.file-max" = 524288;
    };

    programs = {
      steam = {
        enable = true;
        protontricks.enable = true;
        # Open ports in the firewall for Steam Remote Play
        remotePlay.openFirewall = false;
        # Compatibility tools to install
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };

      gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 15;
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
