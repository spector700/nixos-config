{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    concatStringsSep
    mapAttrsToList
    ;
  cfg = config.modules.homelab.pterodactyl.panel.blueprint;
  pterodactylCfg = config.services.pterodactyl.panel;
in
{
  #### ── interface ─────────────────────────────────────────────────────────────
  options.modules.homelab.pterodactyl.panel.blueprint = {
    enable = mkEnableOption "Blueprint framework for Pterodactyl panel";

    themes = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Name of the theme";
            };
            version = mkOption {
              type = types.str;
              description = "Version of the theme";
            };
            source = mkOption {
              type = types.either types.str types.path;
              description = "Source URL or local path of the theme";
            };
          };
        }
      );
      default = { };
      description = "Themes to install for Blueprint";
    };

    extensions = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Name of the extension";
            };
            version = mkOption {
              type = types.str;
              description = "Version of the extension";
            };
            source = mkOption {
              type = types.either types.str types.path;
              description = "Source URL or local path of the extension";
            };
          };
        }
      );
      default = { };
      description = "Extensions to install for Blueprint";
    };
  };

  #### ── implementation ────────────────────────────────────────────────────────
  config = mkIf (pterodactylCfg.enable && cfg.enable) {
    environment.systemPackages = [ pkgs.blueprint ];

    systemd.services.pterodactyl-blueprint = {
      description = "Blueprint framework for Pterodactyl panel";
      wantedBy = [ "multi-user.target" ];
      after = [ "pterodactyl-panel.service" ];

      # runtime tools Blueprint CLI calls
      path = with pkgs; [
        nodejs
        yarn
        zip
        unzip
        git
        curl
        wget
      ];

      # ---------------- Script helpers ----------------
      script =
        let
          extractArchive = source: target: ''
            if [[ "${source}" == *.zip ]]; then
              unzip -o -q "${source}" -d "${target}"
            elif [[ "${source}" == *.tar.gz ]] || [[ "${source}" == *.tgz ]]; then
              tar xzf "${source}" -C "${target}" --strip-components=1
            else
              echo "Unsupported archive format: ${source}"
              exit 1
            fi
          '';

          installTheme = name: theme: ''
            echo "Installing theme ${name}..."
            mkdir -p ${pterodactylCfg.dataDir}/themes/${name}
            ${
              if lib.isString theme.source && (builtins.match "https?://.*" theme.source != null) then
                ''
                  tmpfile=$(mktemp)
                  curl -L "${theme.source}" -o "$tmpfile"
                  ${extractArchive "$tmpfile" "${pterodactylCfg.dataDir}/themes/${name}"}
                  rm "$tmpfile"
                ''
              else
                ''${extractArchive "${theme.source}" "${pterodactylCfg.dataDir}/themes/${name}"}''
            }
            chown -R ${pterodactylCfg.user}:${pterodactylCfg.group} ${pterodactylCfg.dataDir}/themes/${name}
          '';

          installExtension = name: extension: ''
            echo "Installing extension ${name}..."
            mkdir -p ${pterodactylCfg.dataDir}/extensions/${name}
            ${
              if lib.isString extension.source && (builtins.match "https?://.*" extension.source != null) then
                ''
                  tmpfile=$(mktemp)
                  curl -L "${extension.source}" -o "$tmpfile"
                  ${extractArchive "$tmpfile" "${pterodactylCfg.dataDir}/extensions/${name}"}
                  rm "$tmpfile"
                ''
              else
                ''${extractArchive "${extension.source}" "${pterodactylCfg.dataDir}/extensions/${name}"}''
            }
            chown -R ${pterodactylCfg.user}:${pterodactylCfg.group} ${pterodactylCfg.dataDir}/extensions/${name}

            # register extension with Blueprint CLI
            ${pkgs.blueprint}/bin/blueprint install "${name}"
          '';
        in
        ''
                  # ------------------------------------------------------------------
                  # .blueprintrc (Blueprint runtime config)
                  # ------------------------------------------------------------------
                  cat > ${pterodactylCfg.dataDir}/.blueprintrc <<EOF
          WEBUSER="${pterodactylCfg.user}";
          OWNERSHIP="${pterodactylCfg.user}:${pterodactylCfg.group}";
          USERSHELL="/bin/bash";
          EOF
                  chown ${pterodactylCfg.user}:${pterodactylCfg.group} \
                        ${pterodactylCfg.dataDir}/.blueprintrc

                  # ensure themes/extensions dirs exist
                  mkdir -p ${pterodactylCfg.dataDir}/{themes,extensions}
                  chown ${pterodactylCfg.user}:${pterodactylCfg.group} \
                        ${pterodactylCfg.dataDir}/{themes,extensions}

                  # install themes & extensions
                  ${concatStringsSep "\n" (mapAttrsToList installTheme cfg.themes)}
                  ${concatStringsSep "\n" (mapAttrsToList installExtension cfg.extensions)}
        '';

      # ---------------- Service settings ----------------
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = pterodactylCfg.user;
        Group = pterodactylCfg.group;
        WorkingDirectory = pterodactylCfg.dataDir;

        # keep tput happy & point Blueprint at writable workdir
        Environment = [
          "TERM=dumb"
        ];
      };
    };
  };
}
