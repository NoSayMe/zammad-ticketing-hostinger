[← Back to Main README](../README.md)

# Certbot Debugging Guide

This guide shows how to run a standalone Certbot container for manual testing. It uses the same volumes as the main stack so you can inspect the ACME challenge files.

## Usage

Run the helper script from the repository root:

```bash
./certbot-debug.sh yourdomain.com you@example.com
```

The script launches the official `certbot/certbot` image with the `certbot_conf` and `certbot_webroot` volumes mounted. It performs a `--dry-run` certificate request and enables `--debug-challenges` so you can see the challenge file inside `/var/www/certbot`.

While the script is running, open another terminal and verify that NGINX serves the challenge file:

```bash
curl http://yourdomain.com/.well-known/acme-challenge/<token>
```

Press `Ctrl+C` to stop the script or let Certbot finish. No real certificate is issued because the `--dry-run` option uses the Let's Encrypt staging environment.

---
🔗 Back to [Main README](../README.md)
📚 See also: [certbot.md](certbot.md) | [certbot-setup.md](certbot-setup.md)
