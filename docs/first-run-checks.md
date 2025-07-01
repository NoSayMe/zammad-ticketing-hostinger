[← Back to Main README](../README.md)

> **Prerequisite:** Ensure your environment meets the [Requirements & Prerequisites](../README.md#-requirements--prerequisites).

# First Run Checks & Troubleshooting Guide

This guide helps you verify the stack after your first successful deployment and provides steps to debug common issues.

## ✅ What to Expect After a Successful Deploy

- Jenkins pipeline finishes with a **success** status.
- `docker-compose ps` lists all services as `Up`.
- Browse to `https://<your-domain>` and see the welcome page.
- Browse to `https://<your-domain>/zammad` and reach the Zammad setup or login page.

## 🔍 How to Check Container Status

Use these commands to inspect the running containers:

```bash
# List running containers
docker ps
# List services from compose
docker-compose ps
# View container logs
docker logs <container_name>
# Inspect container details
docker inspect <container_name>
# Open a shell inside a container
docker exec -it <container_name> /bin/bash
```

Example checks:

```bash
docker logs zammad
docker exec -it postgres psql -U postgres
```

## 🛠️ Common Issues + Fixes

| Symptom | Possible Cause | What to Check | Fix |
|---------|----------------|---------------|-----|
| Zammad container crashes | No DB | Is Postgres healthy? | Restart stack |
| NGINX shows bad gateway | Wrong proxy port | Check NGINX logs | Fix reverse proxy config |
| Certbot failed | Domain/IP not pointing to VPS | `docker logs certbot` | Fix DNS or rerun deploy |
| Jenkins can't SSH | Credential issue | Check Jenkins logs | Rebind SSH key |

## 🧪 Testing Endpoints

Quickly test that endpoints respond:

```bash
curl -I http://localhost/
curl -I http://localhost/zammad/
```

In a browser watch for:

- "Site not secure" warnings if certificates failed
- Redirect loops
- 404 "Page not found" errors

## 🧼 Resetting or Restarting Stack

To restart without removing volumes:

```bash
docker-compose down
docker-compose up -d
```

Full teardown and cleanup:

```bash
docker-compose down -v --remove-orphans
```

## 📚 Tips for Learning

- Check logs regularly to understand normal behavior.
- Explore container logs to spot unusual errors.
- Access the Zammad CLI:

```bash
docker exec -it zammad bash
zammad run rails c
```

---
🔗 Back to [Main README](../README.md)  
📚 See also: [Troubleshooting](troubleshooting.md) | [Deployment](deployment.md)
