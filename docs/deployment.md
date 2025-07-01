[← Back to Main README](../README.md)

> **Prerequisite:** Review the [Requirements & Prerequisites](../README.md#-requirements--prerequisites). No additional setup is required for this guide.

# Deployment Guide – Zammad Docker Stack

This guide explains how each service in the stack is containerised and where its data is stored. All containers connect to the `zammad-net` Docker network so they can communicate internally.

## 🔐 Credential Management Policy

All credentials for paid services or sensitive infrastructure are stored as Jenkins secrets and injected at runtime. This includes Microsoft 365 OAuth details, DockerHub logins, Certbot email, SSH keys, and your domain/IP settings. Never commit these values to `.env` files or echo them in logs—reference the credential IDs from the `Jenkinsfile`.

| Jenkins ID                              | Purpose |
|-----------------------------------------|---------|
| `github-credentials`                    | SSH key used to pull the repository |
| `dockerhub-credentials`                 | DockerHub login for pushing images |
| `docker-registry`                       | Docker Hub namespace/registry |
| `ssh-remote-server-hostinger-deploy`    | Private key for remote VPS |
| `remote-hostinger-deploy-ip`            | IP address of the server |
| `remote-user`                           | Remote Linux user |
| `remote-hostinger-domain`               | Domain name used for deployment |
| `certbot-email`                         | Email for Let's Encrypt registration |
| `m365-tenant-id`                        | Microsoft 365 tenant ID |
| `m365-client-id`                        | Microsoft 365 application ID |
| `m365-client-secret`                    | Microsoft 365 application secret |
| `m365-smtp-user`                        | SMTP user account |
| `m365-smtp-password`                    | SMTP password/token |
| `m365-shared-mailbox`                   | Shared mailbox address |

## Services

### postgres
Zammad's database backend. Built from `services/postgres/Dockerfile` and configured via environment variables in `.env`. Persistent data is stored in the named volume `postgres_data` mounted at `/var/lib/postgresql/data`.

### elasticsearch
Provides search capabilities for Zammad. Built from `services/elasticsearch/Dockerfile`. The index is kept in `elastic_data` mounted at `/usr/share/elasticsearch/data`.

### zammad
The main application container built from `services/zammad/Dockerfile`. It depends on `postgres` and `elasticsearch`. Application files and attachments are stored in `zammad_data` mounted at `/opt/zammad`.

### nginx
Acts as the reverse proxy and exposes ports 80 and 443. It is built from `services/nginx/Dockerfile` which uses `nginx.conf.template` for its configuration. Certificates and ACME challenge files are shared with the `certbot` container via the volumes `certbot_conf` and `certbot_www`. See the [Certbot guide](certbot.md) for HTTPS configuration details.

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

1. Copy `.env.example` to `.env` and adjust values to suit your environment. The `DOMAIN` entry will be replaced automatically during the Jenkins deployment using the `remote-hostinger-domain` credential.
2. Build and start the containers:
   ```bash
   docker-compose up -d
   ```
3. The application will be available via the domain configured in your DNS pointing to the server. This value is injected as `ZAMMAD_FQDN` and referenced by the NGINX configuration for TLS generation.
4. Visiting the root of your domain displays a simple welcome page with a link to `/zammad`.
5. After the stack is online, follow the [First Run Checks](first-run-checks.md) guide to verify services and troubleshoot any issues.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [CI/CD](ci-cd-pipeline.md) | [Certbot](certbot.md) | [Secrets](secrets.md)
