{
  lib,
  pkgs,
  php,
  cfg,
}:
pkgs.writeShellScript "pterodactyl-user-setup" ''
  set -e
  cd ${cfg.dataDir}
  echo "[+] Creating Pterodactyl users..."

  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: userCfg: ''
      echo "[+] Creating ${userCfg.username}..."
      PASSWORD=$(cat ${userCfg.passwordFile} | tr -d '\r\n')

      if [ -z "$PASSWORD" ] || [ ${"\${#PASSWORD}"} -lt 8 ]; then
        echo "[!] Skipping ${userCfg.username} - password must be at least 8 characters"
      else
        env PASSWORD="$PASSWORD" ${pkgs.su}/bin/su --preserve-environment -s ${pkgs.bash}/bin/bash - ${cfg.user} -c '
          set +o history
          cd ${cfg.dataDir}
          ${php}/bin/php artisan p:user:make \
            --email="${userCfg.email}" \
            --username="${userCfg.username}" \
            --name-first="${userCfg.firstName}" \
            --name-last="${userCfg.lastName}" \
            --password="$PASSWORD" \
            --admin=${if userCfg.isAdmin then "1" else "0"} \
            --no-interaction
        ' || echo "[!] Skipping — user '${userCfg.username}' may already exist."
      fi

      unset PASSWORD
    '') cfg.users
  )}
''
