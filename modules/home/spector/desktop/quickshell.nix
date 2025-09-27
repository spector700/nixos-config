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

in
{
  config = mkIf (cfg == "quickshell") {

    home.packages =
      with pkgs;
      [
        # material-symbols
        # cava
        # mutagen
        hyprpicker
        easyeffects

        inputs.quickshell.packages.${pkgs.system}.default
        kdePackages.kdialog
        kdePackages.qt5compat
        kdePackages.qtbase
        kdePackages.qtdeclarative
        kdePackages.qtdeclarative
        kdePackages.qtimageformats
        kdePackages.qtmultimedia
        kdePackages.qtpositioning
        kdePackages.qtquicktimeline
        kdePackages.qtsensors
        kdePackages.qtsvg
        kdePackages.qttools
        kdePackages.qttranslations
        kdePackages.qtvirtualkeyboard
        kdePackages.qtwayland
        kdePackages.syntax-highlighting
      ]
      ++ (with pkgs; [
        # # AUDIO #
        cava
        lxqt.pavucontrol-qt
        wireplumber
        libdbusmenu-gtk3
        playerctl

        # # BACK LIGNT#
        brightnessctl
        ddcutil

        # # BASIC #
        axel
        bc
        cliphist
        curl
        rsync
        wget
        libqalculate
        ripgrep
        jq
        fuzzel
        matugen
        mpv
        mpvpaper

        xdg-user-dirs

        # # FONT THEMES #
        adw-gtk3
        python313Packages.kde-material-you-colors
        material-symbols
        rubik
        inputs.nur.legacyPackages."${system}".repos.skiletro.gabarito
        # # HYPRLAND #
        wl-clipboard

        # # SCREEN CAPUTUER #
        swappy
        wf-recorder
        hyprshot
        slurp

        # # TOOLKIT #
        wtype
        ydotool

        # # PYTHON #
        #   # clang
        # uv
        #   gtk4
        #   libadwaita
        libsoup_3
        libportal-gtk4
        gobject-introspection
        sassc
        opencv
        (python3.withPackages (
          python-pkgs: with python-pkgs; [
            build
            pillow
            setuptools-scm
            wheel
            pywayland
            psutil
            materialyoucolor
            libsass
            material-color-utilities
            setproctitle
          ]
        ))

        # # WIDGETS #
        glib
        swww
        translate-shell
        wlogout

      ])
      ++ (with pkgs.nerd-fonts; [
        # nerd fonts
        ubuntu
        ubuntu-mono
        jetbrains-mono
        caskaydia-cove
        fantasque-sans-mono
        mononoki
        space-mono
      ]);

    services.gammastep.enable = true;
    services.gammastep.provider = "geoclue2";
    # services.network-manager-applet.enable = true;

    programs.quickshell = {
      enable = true;
      configs = rec {
        end4-ii = "${inputs.end-4_dots-hyprland}/.config/quickshell/ii";
        default = end4-ii;
      };
      activeConfig = "end4-ii";
      systemd.enable = true;
      package = inputs.quickshell.packages.${pkgs.system}.default;
      #   package = pkgs.symlinkJoin {
      #     name = "quickshell-wrapped";
      #     paths = with pkgs; [
      #       inputs.quickshell.packages.${pkgs.system}.default
      #       kdePackages.kdialog
      #       kdePackages.qt5compat
      #       kdePackages.qtbase
      #       kdePackages.qtdeclarative
      #       kdePackages.qtdeclarative
      #       kdePackages.qtimageformats
      #       kdePackages.qtmultimedia
      #       kdePackages.qtpositioning
      #       kdePackages.qtquicktimeline
      #       kdePackages.qtsensors
      #       kdePackages.qtsvg
      #       kdePackages.qttools
      #       kdePackages.qttranslations
      #       kdePackages.qtvirtualkeyboard
      #       kdePackages.qtwayland
      #       kdePackages.syntax-highlighting
      #     ];
      #     meta.mainProgram = pkgs.quickshell.meta.mainProgram;
      #   };
    };

    # systemd.user.services.quickshell-lock = mkIf cfg.enable {
    #   Unit = {
    #     Description = "launch quickshell lock";
    #     Before = "lock.target";
    #   };
    #   Install.WantedBy = [ "lock.target" ];
    #   Service.ExecStart = "${lib.getExe config.programs.quickshell.package} ipc call lock lock";
    # };
  };
}
