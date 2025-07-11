{
  pkgs,
  php,
  composer,
  cfg,
}:
pkgs.writeShellScript "pterodactyl-panel-setup" ''
  set -e
  cd ${cfg.dataDir}

  if [ ! -f artisan ]; then
    echo "[+] Downloading Pterodactyl Panel..."
    ${pkgs.curl}/bin/curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    ${pkgs.busybox}/bin/tar -xzvf panel.tar.gz
    rm panel.tar.gz

    cp .env.example .env
    ${pkgs.sd}/bin/sd '^DB_HOST=.*' 'DB_HOST=${cfg.database.host}' .env
    ${pkgs.sd}/bin/sd '^DB_DATABASE=.*' 'DB_DATABASE=${cfg.database.name}' .env
    ${pkgs.sd}/bin/sd '^DB_USERNAME=.*' 'DB_USERNAME=${cfg.database.user}' .env
    ${pkgs.sd}/bin/sd '^DB_PASSWORD=.*' 'DB_PASSWORD=' .env

    ${composer}/bin/composer install --no-dev --optimize-autoloader
    ${php}/bin/php artisan key:generate --force
    ${php}/bin/php artisan migrate --seed --force

    chown -R ${cfg.user}:${cfg.group} .
  else
    echo "[=] Panel already installed, skipping setup."
  fi
''
