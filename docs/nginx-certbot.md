# NGINX and Certbot Integration

This guide describes how the project uses [Certbot](https://certbot.eff.org/) together with NGINX to obtain and renew free TLS certificates from Let's Encrypt.

## Overview

Certbot automates the process of requesting and renewing certificates. We run it in a Docker container so it can share volumes with our NGINX reverse proxy. The container image is built from [`services/certbot/Dockerfile`](../services/certbot/Dockerfile), which extends the official `certbot/certbot` image. The **webroot** challenge method is used because it only requires serving files from a known directory, making it simple and reliable in a containerized environment.

## Volumes and Files

Two persistent volumes are defined in `docker-compose.yaml`:

- **`certbot_conf`** – stores all certificate data under `/etc/letsencrypt`. This volume keeps the private key and renewal configuration across container restarts.
- **`certbot_www`** – mapped to `/var/www/certbot` and served by NGINX. Certbot places challenge files here so Let's Encrypt can verify domain ownership.

On the server these volumes are managed by Docker and typically live under `/var/lib/docker/volumes/`.

## How It Works

1. **One‑time certificate request** – during deployment `deploy-script.sh` checks if `certbot_conf` already contains a certificate for `${REMOTE_DOMAIN}`. If not, it runs a one-off Certbot container to request it using the webroot method.
2. **Automatic renewal** – the `certbot` service runs in a loop and calls `certbot renew` every 12 hours. Renewed certificates are written to `certbot_conf` and automatically picked up by NGINX after reload.
3. **ACME challenge handling** – NGINX exposes `/.well-known/acme-challenge/` from the `certbot_www` volume so Let's Encrypt can reach the challenge files created by Certbot.

## TLS Configuration

NGINX uses the certificates from `/etc/letsencrypt/live/${REMOTE_DOMAIN}`:

```nginx
ssl_certificate /etc/letsencrypt/live/${REMOTE_DOMAIN}/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/${REMOTE_DOMAIN}/privkey.pem;
```

The full NGINX configuration is stored in [`services/nginx/conf.d/zammad.conf`](../services/nginx/conf.d/zammad.conf) and mounts both Certbot volumes so these paths are available inside the container.

## Troubleshooting

- **Certificate not renewing** – check the Certbot logs with `docker logs certbot`. Errors usually indicate network or DNS issues.
- **Manually rerun** – if renewal fails repeatedly you can rerun the one‑time command:
  ```bash
  docker run --rm -v certbot_conf:/etc/letsencrypt \
    -v certbot_www:/var/www/certbot \
    certbot/certbot certonly --webroot -w /var/www/certbot \
    --email <your-email> --agree-tos --no-eff-email -d ${REMOTE_DOMAIN}
  ```

## References

- [Certbot Documentation](https://eff-certbot.readthedocs.io/en/stable/)
- [`docker-compose.yaml`](../docker-compose.yaml)
- [`services/nginx/conf.d/zammad.conf`](../services/nginx/conf.d/zammad.conf)
