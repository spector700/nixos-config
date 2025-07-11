{
  pkgs,
  lib,
  cfg,
}:
let
  # Helper function to escape single quotes for SQL
  escapeSQL = str: builtins.replaceStrings [ "'" ] [ "''" ] str;

  # Generate a UUID for a node
  generateUUID =
    name: "00000000-0000-0000-0000-${lib.substring 0 12 (builtins.hashString "sha256" name)}";

  # Get all declared node IDs
  declaredNodeNames = builtins.attrNames cfg.nodes;

  # Delete query for nodes that are no longer declared
  deleteNodesQuery =
    if declaredNodeNames == [ ] then
      null
    else
      ''
        DELETE FROM nodes
        WHERE name NOT IN (${lib.concatStringsSep ", " (map (s: "'${escapeSQL s}'") declaredNodeNames)});
      '';

  mysqlCmd = "${pkgs.mariadb}/bin/mysql --user='${cfg.database.user}' --database='${cfg.database.name}' --protocol=SOCKET";

  # Create or update a node
  mkNodeUpsert =
    name: node:
    let
      # Get location ID for this node
      locationIdQuery = ''
        SELECT id FROM locations WHERE short = '${escapeSQL node.location}' LIMIT 1;
      '';

      # Escape all string values
      nodeName = escapeSQL node.name;
      nodeDesc = escapeSQL node.description;
      nodeFqdn = escapeSQL node.fqdn;
      nodeScheme = escapeSQL node.scheme;
      nodeDaemonTokenIdPath = node.daemonTokenId;
      nodeDaemonTokenPath = node.daemonToken;
      nodeDaemonBase = escapeSQL node.daemonBase;

      # Convert booleans to 0/1
      behindProxy = if node.behindProxy then "1" else "0";
      maintenanceMode = if node.maintenanceMode then "1" else "0";

      # Generate UUID for this node
      uuid = generateUUID name;
    in
    ''
      # Get location ID for node ${nodeName}
      LOCATION_ID=$(${mysqlCmd} -sN -e "SELECT id FROM locations WHERE short = '${escapeSQL node.location}' LIMIT 1")

      if [ -z "$LOCATION_ID" ]; then
        echo "Error: Location '${node.location}' not found for node '${nodeName}'"
        exit 1
      fi

      # Read token values from files
      DAEMON_TOKEN_ID=$(cat "${nodeDaemonTokenIdPath}")
      DAEMON_TOKEN=$(cat "${nodeDaemonTokenPath}")

      # Insert or update node
      cat <<EOF | ${mysqlCmd}
      INSERT INTO nodes (
        uuid, public, name, description, location_id, fqdn, scheme,
        behind_proxy, maintenance_mode, memory, memory_overallocate,
        disk, disk_overallocate, upload_size, daemon_token_id, daemon_token,
        daemonListen, daemonSFTP, daemonBase, created_at, updated_at
      )
      VALUES (
        '${uuid}', 1, '${nodeName}', '${nodeDesc}', $LOCATION_ID, '${nodeFqdn}', '${nodeScheme}',
        ${behindProxy}, ${maintenanceMode}, ${toString node.memory}, ${toString node.memoryOverallocate},
        ${toString node.disk}, ${toString node.diskOverallocate}, ${toString node.uploadSize},
        '$DAEMON_TOKEN_ID', '$DAEMON_TOKEN', ${toString node.daemonListen},
        ${toString node.daemonSFTP}, '${nodeDaemonBase}', NOW(), NOW()
      )
      ON DUPLICATE KEY UPDATE
        description = '${nodeDesc}',
        location_id = $LOCATION_ID,
        fqdn = '${nodeFqdn}',
        scheme = '${nodeScheme}',
        behind_proxy = ${behindProxy},
        maintenance_mode = ${maintenanceMode},
        memory = ${toString node.memory},
        memory_overallocate = ${toString node.memoryOverallocate},
        disk = ${toString node.disk},
        disk_overallocate = ${toString node.diskOverallocate},
        upload_size = ${toString node.uploadSize},
        daemon_token_id = '$DAEMON_TOKEN_ID',
        daemon_token = '$DAEMON_TOKEN',
        daemonListen = ${toString node.daemonListen},
        daemonSFTP = ${toString node.daemonSFTP},
        daemonBase = '${nodeDaemonBase}',
        updated_at = NOW();
      EOF
    '';

  # Process allocations for a node
  mkAllocationSetup =
    name: node:
    let
      # Get node ID for this node
      nodeIdQuery = ''
        SELECT id FROM nodes WHERE name = '${escapeSQL node.name}' LIMIT 1;
      '';

      # Delete allocations that are no longer declared for this node
      deleteAllocationsQuery = ''
        DELETE FROM allocations
        WHERE node_id = $NODE_ID
          AND server_id IS NULL;
      '';

      # Create allocation inserts
      mkAllocationInsert = alloc: ''
        INSERT INTO allocations (
          node_id, ip, ip_alias, port, notes, created_at, updated_at
        )
        SELECT
          $NODE_ID,
          '${escapeSQL alloc.ip}',
          ${if alloc.ipAlias != null then "'${escapeSQL alloc.ipAlias}'" else "NULL"},
          ${toString alloc.port},
          ${if alloc.notes != null then "'${escapeSQL alloc.notes}'" else "NULL"},
          NOW(),
          NOW()
        FROM dual
        WHERE NOT EXISTS (
          SELECT 1 FROM allocations
          WHERE node_id = $NODE_ID
            AND ip = '${escapeSQL alloc.ip}'
            AND port = ${toString alloc.port}
        );
      '';

      allocationInserts = lib.concatStringsSep "\n" (map mkAllocationInsert node.allocations);
    in
    ''
      # Get node ID for ${node.name}
      NODE_ID=$(${mysqlCmd} -sN -e "SELECT id FROM nodes WHERE name = '${escapeSQL node.name}' LIMIT 1")

      if [ -z "$NODE_ID" ]; then
        echo "Error: Node '${node.name}' not found"
        exit 1
      fi

      # Delete unused allocations
      cat <<EOF | ${mysqlCmd}
      ${deleteAllocationsQuery}
      EOF

      # Create new allocations
      ${
        if node.allocations != [ ] then
          ''
            cat <<EOF | ${mysqlCmd}
            ${allocationInserts}
            EOF
          ''
        else
          "echo 'No allocations to create for node ${node.name}'"
      }
    '';
in
pkgs.writeShellScript "pterodactyl-node-setup" ''
  set -e

  echo "[+] Setting up Pterodactyl nodes..."

  ${
    if deleteNodesQuery != null then
      ''
        echo "[+] Cleaning up undeclared nodes..."
        echo "${deleteNodesQuery}" | ${mysqlCmd}
      ''
    else
      ''
        echo "[=] No nodes declared; skipping cleanup."
      ''
  }

  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: node: ''
      echo "[+] Setting up node: ${node.name}..."
      ${mkNodeUpsert name node}

      echo "[+] Setting up allocations for node: ${node.name}..."
      ${mkAllocationSetup name node}
    '') cfg.nodes
  )}

  echo "[+] Node setup complete!"
''
