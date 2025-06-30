# Deployment Guide – Zammad Docker Stack

This guide explains how each service in the stack is containerised and where its data is stored. All containers connect to the `zammad-net` Docker network so they can communicate internally.

## Services

### postgres
Zammad's database backend. Built from `services/postgres/Dockerfile` and configured via environment variables in `.env`. Persistent data is stored in the named volume `postgres_data` mounted at `/var/lib/postgresql/data`.

### elasticsearch
Provides search capabilities for Zammad. Built from `services/elasticsearch/Dockerfile`. The index is kept in `elastic_data` mounted at `/usr/share/elasticsearch/data`.

### zammad
The main application container built from `services/zammad/Dockerfile`. It depends on `postgres` and `elasticsearch`. Application files and attachments are stored in `zammad_data` mounted at `/opt/zammad`.

### nginx
Acts as the reverse proxy and exposes ports 80 and 443. It is built from `services/nginx/Dockerfile` which uses `nginx.conf.template` for its configuration. Certificates and ACME challenge files are shared with the `certbot` container via the volumes `certbot_conf` and `certbot_www`.

### certbot
Handles Let's Encrypt certificate issuance and renewal. The container is built from [`services/certbot/Dockerfile`](../services/certbot/Dockerfile), which uses the official `certbot/certbot` image as its base. It shares the same volumes as NGINX for certificate storage.

## Persistent Volumes

```yaml
volumes:
  zammad_data:
  postgres_data:
  elastic_data:
  certbot_conf:
  certbot_www:
```

These volumes are defined in `docker-compose.yaml` and ensure data is retained across container restarts or upgrades.

## Running the stack

1. Copy `.env.example` to `.env` and adjust values to suit your environment.
   The `DOMAIN` entry will be replaced automatically during the Jenkins deployment
   using the `remote-hostinger-domain` credential.
2. Build and start the containers:
   ```bash
   docker-compose up -d
   ```
3. The application will be available via the domain configured in your DNS pointing to the server.
   This value is injected as `ZAMMAD_FQDN` and referenced by the NGINX configuration for TLS generation.
4. Visiting the root of your domain displays a simple welcome page with a link to `/zammad`.
