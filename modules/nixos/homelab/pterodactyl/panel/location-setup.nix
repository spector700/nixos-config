{
  pkgs,
  lib,
  cfg,
}:
let
  declaredShorts = builtins.attrNames cfg.locations;

  deleteQuery =
    if declaredShorts == [ ] then
      null
    else
      ''
        DELETE FROM locations
        WHERE short NOT IN (${lib.concatStringsSep ", " (map (s: "'${s}'") declaredShorts)})
          AND id NOT IN (SELECT location_id FROM nodes);
      '';

  # Helper function to escape single quotes for SQL
  escapeSQL = str: builtins.replaceStrings [ "'" ] [ "''" ] str;

  mkInsertOrUpdate =
    name: loc:
    let
      short = escapeSQL loc.short;
      long = escapeSQL loc.long;
    in
    ''
      INSERT INTO locations (\`short\`, \`long\`, \`created_at\`, \`updated_at\`)
      VALUES ('${short}', '${long}', NOW(), NOW())
      ON DUPLICATE KEY UPDATE \`long\` = '${long}', \`updated_at\` = NOW();
    '';

  mysqlCmd = "${pkgs.mariadb}/bin/mysql --user='${cfg.database.user}' --database='${cfg.database.name}' --protocol=SOCKET";
in
pkgs.writeShellScript "pterodactyl-location-setup" ''
  set -e
  ${
    if deleteQuery != null then
      ''
        echo "[+] Cleaning up undeclared locations..."
        echo "${deleteQuery}" | ${mysqlCmd}
      ''
    else
      ''
        echo "[=] No locations declared; skipping cleanup."
      ''
  }

  echo "[+] Upserting declared locations..."
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: loc: ''
      echo "${mkInsertOrUpdate name loc}" | ${mysqlCmd}
    '') cfg.locations
  )}
''
