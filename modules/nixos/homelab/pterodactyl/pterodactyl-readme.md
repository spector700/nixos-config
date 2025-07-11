# 🛠️ Pterodactyl NixOS Module (Panel + Wings)

This NixOS module automates the installation and configuration of both the
Pterodactyl Panel and Wings daemon on a single server. While the module handles
most of the setup, a few manual steps are required to complete the integration.

---

## ✅ Prerequisites

- **Domain Configuration**: Ensure DNS records are set up for both the Panel
  (e.g., `panel.example.com`) and Wings (e.g., `wings.example.com`).
- **SSL Certificates**: Obtain SSL certificates for your domains, either through
  Let's Encrypt or another provider.
- **Reverse Proxy**: Configure a reverse proxy (e.g., NGINX) to handle HTTPS
  connections for both the Panel and Wings.

---

## ⚙️ Module Configuration

In your NixOS configuration, enable and configure both the Panel and Wings:

```nix
services.pterodactyl = {
  panel = {
    enable = true;
    # Panel-specific configurations
  };
  wings = {
    enable = true;
    settings = {
      api = {
        ssl.enabled = false;
        port = 8080;
      };
      remote = "https://panel.example.com";
      ignore_panel_config_updates = false;
    };
  };
};
```

- **`api.port`**: Set to `8080` to run Wings internally on this port.
- **`remote`**: URL of your Pterodactyl Panel.
- **`ignore_panel_config_updates`**: Set to `false` to allow the Panel to manage
  the Wings configuration.

---

## 📝 Manual Setup Steps

### 1. Create a Node in the Panel

1. Log in to your Pterodactyl Panel as an administrator.
2. Navigate to **Admin > Nodes**.
3. Click **Create New** and fill in the required details:
   - **Name**: Descriptive name for your node.
   - **FQDN**: Domain pointing to your Wings server (e.g., `wings.example.com`).
   - **SSL Configuration**:
     - **Use SSL Connection**: Enabled.
     - **Behind Proxy**: Enabled.
   - **Daemon Port**: Set to `443` (as the reverse proxy will handle SSL
     termination).
   - **Resource Allocation**: Specify memory and disk limits.
4. Click **Create Node**.

### 2. Obtain and Apply the Configuration

1. After creating the node, navigate to the **Configuration** tab of the node.
2. Copy the provided YAML configuration.
3. On your server, open the existing Wings configuration file:

   ```bash
   sudo nano /var/lib/pterodactyl/wings.yaml
   ```

4. Locate the following fields and update them with the values from the Panel:
   - `uuid`
   - `token_id`
   - `token` Ensure that the rest of the configuration remains unchanged.
5. Save and close the file.

### 3. Restart the Wings Service

Apply the new configuration by restarting the Wings service:

```bash
sudo systemctl restart wings.service
```

### 4. Configure Allocations

1. In the Panel, go to **Admin > Nodes** and select your node.
2. Navigate to the **Allocations** tab.
3. Click **Create New** and specify:
   - **IP Address**: Typically `0.0.0.0` to bind to all interfaces.
   - **Alias**: Your domain (e.g., `wings.example.com`).
   - **Ports**: Define the range of ports for game servers (e.g.,
     `25565-25570`).
4. Click **Create Allocation**.

### 5. Create Servers

With allocations in place, you can now create and deploy game servers through
the Panel.

---

## 🔄 Notes on Configuration Sync

- **Panel Overrides**: Since `ignore_panel_config_updates` is set to `false`,
  the Panel will manage the Wings configuration. Ensure that any manual changes
  to `wings.yaml` are also reflected in the Panel to prevent overwrites.
- **Internal vs. External Ports**: Wings runs internally on port `8080`, while
  the reverse proxy exposes it on port `443`. The Panel communicates with Wings
  over `443`, but Wings itself listens on `8080`.

---

## 🧪 Troubleshooting

- **Node Offline**: If the node appears offline in the Panel:
  - Verify that the reverse proxy is correctly forwarding requests to Wings.
  - Check that the SSL certificates are valid and properly configured.
  - Ensure that the `wings.yaml` file contains the correct `uuid`, `token_id`,
    and `token` values.
- **Configuration Issues**: If Wings fails to start:
  - Validate the YAML syntax of `wings.yaml` using a linter.
  - Check the Wings logs for detailed error messages:
