[← Back to Main README](../README.md)

> **Prerequisite:** Review the [Requirements & Prerequisites](../README.md#-requirements--prerequisites). No extra dependencies beyond a configured domain.

# NGINX and Certbot Integration

This guide describes how the project uses [Certbot](https://certbot.eff.org/) together with NGINX to obtain and renew free TLS certificates from Let's Encrypt.

> **⚠️ Sensitive Keys**
> All required keys and secrets for this integration are injected securely via Jenkins and are not stored in this repository.

## Overview

Certbot automates the process of requesting and renewing certificates. We run it in a Docker container so it can share volumes with our NGINX reverse proxy. The container image is built from [`services/certbot/Dockerfile`](../services/certbot/Dockerfile), which extends the official `certbot/certbot` image. The **webroot** challenge method is used because it only requires serving files from a known directory, making it simple and reliable in a containerized environment.

## Volumes and Files

Two persistent locations are defined in `docker-compose.yaml`:

- **`certbot_conf`** – stores all certificate data under `/etc/letsencrypt`. This volume keeps the private key and renewal configuration across container restarts.
- **`certbot_www`** – directory `./certbot/www` mapped to `/var/www/certbot` and served by NGINX. Certbot places challenge files here so Let's Encrypt can verify domain ownership.

Both volumes **must** be mounted in **both** the NGINX and Certbot containers. If the webroot path isn't shared correctly, Certbot may fail with unexpected errors.

On the server these volumes are managed by Docker and typically live under `/var/lib/docker/volumes/`.

## Webroot Validation Setup

Before requesting a certificate, verify that NGINX serves the challenge directory and that the Certbot container can write to it. In `services/nginx/default.conf.template` you should see:

```nginx
location /.well-known/acme-challenge/ {
    root /var/www/certbot;
}
```

Both containers mount the same directory for challenges:

```yaml
volumes:
  - ./certbot/www:/var/www/certbot
```

Run these checks if the challenge fails:

```bash
curl http://<domain>/.well-known/acme-challenge/testfile
dig +short <domain>
docker exec nginx curl -s localhost/.well-known/acme-challenge/testfile
docker exec certbot ls /var/www/certbot
```

All commands should succeed and return the expected data. If not, confirm your DNS points to the VPS IPv4 address and that the volumes are shared correctly.

## How It Works

1. **One‑time certificate request** – during deployment `deploy-script.sh` checks if `certbot_conf` already contains a certificate for `${REMOTE_DOMAIN}`. If not, it runs a one-off Certbot container to request it using the webroot method.
2. **Automatic renewal** – the `certbot` service runs in a loop and calls `certbot renew` every 12 hours. Renewed certificates are written to `certbot_conf` and automatically picked up by NGINX after reload.
3. **ACME challenge handling** – NGINX exposes `/.well-known/acme-challenge/` from the `./certbot/www` directory so Let's Encrypt can reach the challenge files created by Certbot.

### Initial Certificate Request

Run this command once (inside or outside the container) to obtain the first certificate. Replace the domain and email with your real values:

```bash
docker run --rm \
  -v certbot_conf:/etc/letsencrypt \
  -v ./certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot \
  --webroot-path /var/www/certbot \
  -d yourdomain.com \
  --non-interactive \
  --agree-tos \
  --email you@example.com \
  --no-eff-email
```

Port **80** must be reachable and NGINX must route `/.well-known/acme-challenge/` to `/var/www/certbot` for this step to succeed. Certificates are stored under `/etc/letsencrypt/live/yourdomain.com/` inside the `certbot_conf` volume.

### Using the Certificates in NGINX

Mount the `certbot_conf` volume in the NGINX service so the certificates are available without copying them into Jenkins:

```yaml
services:
  nginx:
    volumes:
      - certbot_conf:/etc/letsencrypt
```

Reference the files directly in `nginx.conf`:

```nginx
ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
```

NGINX reads these paths live from the mounted volume, so a reload is enough after renewal.

### Auto‑Renewal

The running `certbot` container periodically checks and renews certificates. One approach is a simple loop inside the container:

```yaml
certbot:
  image: certbot/certbot
  volumes:
    - ./certbot/www:/var/www/certbot
    - certbot_conf:/etc/letsencrypt
  entrypoint: >
    sh -c "trap exit TERM; while :; do
      certbot renew --webroot --webroot-path=/var/www/certbot && \
      nginx -s reload; \
      sleep 12h; \
    done"
```

Alternatively your Jenkins pipeline can run `docker exec certbot certbot renew` on a schedule and then reload NGINX with `docker exec nginx nginx -s reload`.

### Jenkins Secrets

Jenkins only stores the domain and email used for Certbot. The certificate files remain solely in the Docker volume.

| Secret Name                | Purpose       |
|----------------------------|---------------|
| `remote-hostinger-domain`  | Domain pointed to the VPS       |
| `certbot-email`            | Email address for Let's Encrypt registration       |

These secrets are injected into `.env` during the pipeline so the services know the domain and email to use. The `certbot-email` secret becomes the `CERTBOT_EMAIL` environment variable passed to `deploy-script.sh`.

### Verification

Check existing certificates with:

```bash
docker exec certbot certbot certificates
```

Test renewal logic without affecting real certificates:

```bash
docker exec certbot certbot renew --dry-run
```

Finally verify HTTPS access:

```bash
curl -I https://yourdomain.com
```

The response should be `200 OK` and your browser should show a valid certificate.

## TLS Configuration

NGINX uses the certificates from `/etc/letsencrypt/live/${REMOTE_DOMAIN}`:

```nginx
ssl_certificate /etc/letsencrypt/live/${REMOTE_DOMAIN}/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/${REMOTE_DOMAIN}/privkey.pem;
```

The full NGINX configuration is stored in [`services/nginx/default.conf.template`](../services/nginx/default.conf.template) and mounts the Certbot volumes so these paths are available inside the container. See the [Deployment guide](deployment.md) for how the container is started.

## Troubleshooting

- **Certificate not renewing** – check the Certbot logs with `docker logs certbot`. Errors usually indicate network or DNS issues.
- **Manually rerun** – if renewal fails repeatedly you can rerun the one‑time command:
  ```bash
  docker run --rm -v certbot_conf:/etc/letsencrypt \
    -v ./certbot/www:/var/www/certbot \
    certbot/certbot certonly --webroot \
    --webroot-path /var/www/certbot \
    -d ${REMOTE_DOMAIN} \
    --non-interactive \
    --agree-tos \
    --email <your-email> \
    --no-eff-email
  ```

## References

- [Certbot Documentation](https://eff-certbot.readthedocs.io/en/stable/)
- [`docker-compose.yaml`](../docker-compose.yaml)
- [`services/nginx/nginx.conf.template`](../services/nginx/nginx.conf.template)

---
🔗 Back to [Main README](../README.md)  
📚 See also: [Deployment](deployment.md) | [CI/CD](ci-cd-pipeline.md) | [Secrets](secrets.md)
