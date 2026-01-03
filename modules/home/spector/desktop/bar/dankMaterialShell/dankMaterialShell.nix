{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.modules.desktop.bar;

  inherit (config.lib.stylix) colors;
  colorTheme = {
    dark = with colors.withHashtag; {
      name = "Stylix generatated dark theme";
      primary = base0D;
      primaryText = base00;
      primaryContainer = base0C;
      secondary = base0E;
      surface = base01;
      surfaceText = base05;
      surfaceVariant = base02;
      surfaceVariantText = base04;
      surfaceTint = base0F;
      background = base00;
      backgroundText = base05;
      outline = base03;
      surfaceContainer = base01;
      surfaceContainerHigh = base02;
      surfaceContainerHighest = base03;
      error = base08;
      warning = base0A;
      info = base0C;
    };
    light = with colors.withHashtag; {
      name = "Stylix generatated light theme";
      primary = base0D;
      primaryText = base07;
      primaryContainer = base0C;
      secondary = base0E;
      surface = base06;
      surfaceText = base01;
      surfaceVariant = base07;
      surfaceVariantText = base02;
      surfaceTint = base0D;
      background = base07;
      backgroundText = base00;
      outline = base04;
      surfaceContainer = base06;
      surfaceContainerHigh = base05;
      surfaceContainerHighest = base04;
      error = base08;
      warning = base0A;
      info = base0C;
    };
  };

  # Material Symbols Rounded font derivation
  material-symbols-rounded = pkgs.stdenvNoCC.mkDerivation {
    pname = "material-symbols-rounded";
    version = "2024-09-01";

    src = pkgs.fetchurl {
      url = "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf";
      hash = "sha256-1xnyL97ifjRLB+Rub6i1Cx/OPPywPUqE8D+vvwgS/CI=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 $src $out/share/fonts/truetype/MaterialSymbolsRounded.ttf
      runHook postInstall
    '';

    meta = with lib; {
      description = "Material Symbols Rounded - Variable icon font by Google";
      homepage = "https://fonts.google.com/icons";
      license = licenses.asl20;
      platforms = platforms.all;
    };
  };

in
{
  imports = [ inputs.dankMaterialShell.homeModules.dank-material-shell ];

  config = mkIf (cfg == "dankMaterialShell") {

    home.packages = with pkgs; [
      hyprpicker
      jq
      material-symbols-rounded
    ];

    home.sessionVariables = {
      DMS_DISABLE_MATUGEN = "1";
    };

    services.gammastep = {
      enable = true;
      provider = "geoclue2";
    };

    programs.dank-material-shell = {
      enable = true;
      systemd.enable = false;
      # enableBrightnessControl = mkIf config.modules.roles.laptop.enable;
    };

    xdg.configFile."DankMaterialShell/stylix-colors.json".text = builtins.toJSON colorTheme;
    # xdg.configFile."DankMaterialShell/settings.json" = {
    #   source = ./settings.json;
    # };

    wayland.windowManager.hyprland = {
      settings = {
        exec-once = [
          "sleep 2 && dms run"
        ];

        bind = [
          "$mod, comma, exec, dms ipc call settings toggle"
          "$mod CTRL, q, exec, dms ipc call lock lock"

          # "$mod, Space, exec, dms ipc call spotlight toggle"
          "$mod, P, exec, dms ipc call clipboard toggle"
        ];

        layerrule = [
          "blur, quickshell:bar"
        ];
      };
    };

  };
}
