[← Back to Main README](../README.md)

# NGINX and Certbot Configuration

This guide explains how the NGINX reverse proxy and Certbot container work together to provide HTTPS for your domain.

## Directory Structure

```
services/nginx/              # Dockerfile and config templates
certbot/www/                 # ACME challenge files served by NGINX
```

NGINX loads global settings from `services/nginx/nginx.conf` and includes all files under `/etc/nginx/conf.d/`. The main virtual host logic is rendered from `conf.d/default.conf.template` (HTTPS) or `conf.d/default.http.conf.template` when no certificate exists.

## Cloudflare Proxy Warning

> **Important:** For the first SSL certificate generation you must disable Cloudflare proxying for your domain. Set the DNS records to **DNS only** so Let's Encrypt can reach the challenge files. Re‑enable the proxy after the certificate is issued if desired.

## Validation Commands

After starting the containers, verify that the challenge directory is reachable:

```bash
# Create a test file in the webroot
sudo docker run --rm -v ./certbot/www:/var/www/certbot busybox sh -c 'echo hello > /var/www/certbot/test.txt'

# Fetch it through NGINX
curl http://yourdomain.com/.well-known/acme-challenge/test.txt
```

Both commands should output `hello`.

## Example First-Time Certificate Request

1. Disable Cloudflare proxying.
2. Ensure ports 80/443 are open to the VPS.
3. Run the deployment script which performs a pre-check and requests the certificate:

```bash
./deploy-script.sh <registry> <server-ip> yourdomain.com you@example.com
```

If the test file is reachable, Certbot will obtain the certificate and NGINX will automatically reload.

## Troubleshooting `"server" directive is not allowed here`

If NGINX fails to start with an error like:

```
nginx: [emerg] "server" directive is not allowed here in /etc/nginx/nginx.conf:1
```

it means a `server {}` block was placed directly inside `nginx.conf`. Only global settings and the `http {}` block belong in that file. Move any `server {}` block into its own file under `/etc/nginx/conf.d/` (for example `default.conf`). After adjusting the files, test the configuration inside the container:

```bash
nginx -t
```

This command should report `syntax is ok` and `test is successful`.

---
🔗 Back to [Main README](../README.md)
📚 See also: [certbot.md](certbot.md) | [deployment](deployment.md)
