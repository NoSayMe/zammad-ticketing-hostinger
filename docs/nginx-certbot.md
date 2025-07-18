[← Back to Main README](../README.md)

# NGINX and Certbot Configuration

This guide explains how the NGINX reverse proxy and Certbot container work together to provide HTTPS for your domain.

## Directory Structure

```
services/nginx/              # Dockerfile and config templates
```

NGINX loads global settings from `services/nginx/nginx.conf` and includes all files under `/etc/nginx/conf.d/`. If `nginx.conf` is missing when the image is built, the Dockerfile falls back to `default.conf.template` and prints a warning. During container start the entrypoint checks if `/etc/nginx/conf.d/default.conf` exists. If not, it generates one from `conf.d/default.conf.template` (HTTPS) or `conf.d/default.http.conf.template` when no certificate is present. This behaviour is handled by the helper script `ensure-config.sh` and lets you mount your own `default.conf` to override the template.

## Volume Mount Strategy

Both the NGINX and Certbot containers share a named volume `certbot_webroot` mounted to `/var/www/certbot`. Challenge files created by Certbot appear instantly inside NGINX:

```yaml
volumes:
  certbot_webroot:
  certbot_conf:

services:
  nginx:
    volumes:
      - certbot_webroot:/var/www/certbot
      - certbot_conf:/etc/letsencrypt
  certbot:
    volumes:
      - certbot_webroot:/var/www/certbot
      - certbot_conf:/etc/letsencrypt
```

## NGINX Challenge Location

Make sure the HTTP server block serves the challenge directory without redirects or rewrites:

```nginx
location /.well-known/acme-challenge/ {
    alias /var/www/certbot/;
}
```

## Cloudflare Proxy Warning

> **Important:** For the first SSL certificate generation you must disable Cloudflare proxying for your domain. Set the DNS records to **DNS only** so Let's Encrypt can reach the challenge files. Re‑enable the proxy after the certificate is issued if desired.

## Validation Commands

After starting the containers, verify that the challenge directory is reachable:

```bash
# Create a test file in the shared volume
docker run --rm -v certbot_webroot:/var/www/certbot busybox sh -c 'echo hello > /var/www/certbot/test.txt'

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

Alternatively, request the certificate manually:

```bash
docker run --rm \
  -v certbot_conf:/etc/letsencrypt \
  -v certbot_webroot:/var/www/certbot \
  certbot/certbot certonly --webroot \
  -w /var/www/certbot \
  -d yourdomain.com \
  --non-interactive \
  --agree-tos \
  --email you@example.com
```

If the test file is reachable, Certbot will obtain the certificate and NGINX will automatically reload. The deployment script now writes a temporary `.well-known-check.txt` file and repeatedly checks it before requesting a certificate, preventing false 404 errors when NGINX is still starting.

## Common ACME Challenge Errors

- `404 Not Found` when fetching the challenge file. Confirm that `certbot_webroot` is mounted in both containers and that the path resolves with `docker exec nginx ls -l /var/www/certbot/.well-known/acme-challenge`.
- Missing `/.well-known/acme-challenge/` block in `default.conf`. The container entrypoint now injects this block automatically if it's absent, but verify the server config contains:
```nginx
location /.well-known/acme-challenge/ {
    alias /var/www/certbot/;
}
```
Then reload NGINX.
- DNS pointing to the wrong IP. Run `dig +short yourdomain.com` and ensure it matches the server.

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

