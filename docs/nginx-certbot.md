# NGINX and Certbot

This document explains how the reverse proxy container works together with Certbot to provide HTTPS certificates.

NGINX serves as a reverse proxy in front of the Zammad application. The configuration in `services/nginx/conf.d/zammad.conf` forwards traffic to the `zammad` container and exposes the `/.well-known/acme-challenge/` path for Let's Encrypt validation.
The root of the domain serves a static `index.html` page and any requests under `/zammad` are proxied to the Zammad container.

The `certbot` container shares two volumes with NGINX:

- `certbot_conf` - stores issued certificates under `/etc/letsencrypt`
- `certbot_www` - served by NGINX under `/var/www/certbot` for HTTP-01 challenges

During renewal the certbot container runs a loop which calls `certbot renew` every 12 hours. NGINX uses the same certificate files from `certbot_conf` so renewed certificates are picked up automatically after reload.
