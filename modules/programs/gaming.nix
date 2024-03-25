# Gaming
#
# Do not forget to enable Steam capatability for all title in the settings menu
#
{ pkgs, lib, config, inputs, ... }:
# {
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.modules.programs.gaming;
in
{
  options.modules.programs.gaming = {
    enable = mkEnableOption "Enable packages required for the device to be gaming-ready";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      lutris
      inputs.nix-citizen.packages.${pkgs.system}.star-citizen
      # Minecraft
      prismlauncher
      protontricks
      # Steam theme
      adwsteamgtk
    ];

    # NixOS configuration for Star Citizen requirements
    boot.kernel.sysctl = {
      "vm.max_map_count" = 16777216;
      "fs.file-max" = 524288;
    };

    nixpkgs.overlays = [
      (_: prev: {
        steam = prev.steam.override ({ extraPkgs ? _: [ ], ... }: {
          extraPkgs = pkgs':
            (extraPkgs pkgs')
            # Add missing dependencies for unsteam games
            ++ (with pkgs'; [
              # Generic dependencies
              libgdiplus
              keyutils
              libkrb5
              libpng
              libpulseaudio
              libvorbis
              stdenv.cc.cc.lib
              xorg.libXcursor
              xorg.libXi
              xorg.libXinerama
              xorg.libXScrnSaver
              at-spi2-atk
              fmodex
              gtk3
              gtk3-x11
              harfbuzz
              icu
              glxinfo
              inetutils
              libthai
              mono5
              pango
              stdenv.cc.cc.lib
              strace
              zlib
            ]);
        });
      })
    ];

    programs = {
      steam = {
        enable = true;

        # Open ports in the firewall for Steam Remote Play
        remotePlay.openFirewall = false;

        # Compatibility tools to install
        extraCompatPackages = with pkgs; [ proton-ge-bin.steamcompattool ];
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
  };
}
