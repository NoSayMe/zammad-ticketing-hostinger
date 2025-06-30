# CI/CD Pipeline Overview

This document outlines the proposed Jenkins-based CI/CD workflow for deploying the Zammad ticketing system to a Hostinger VPS. It expands on the existing example pipeline (`Jenkinsfile`, `deploy-script.sh`, and `docker-compose.yaml`) and reuses predefined Jenkins credentials.

## Pipeline Stages

1. **Checkout**
   - Uses `github-credentials` to securely pull the repository via SSH.
2. **Docker Build**
   - Build custom images if needed (e.g., organization-specific branding).
   - Tag images using the value stored in the `docker-registry` credential.
3. **Docker Push**
   - Authenticate to Docker Hub with `dockerhub-credentials` and push the freshly built images to the registry namespace.
4. **Remote Deploy**
   - SSH into the Hostinger VPS with `ssh-remote-server-hostinger-deploy` using the host from `remote-hostinger-deploy-ip` and user provided by `remote-user`.
   - Run `deploy-script.sh`, passing `DOCKER_REGISTRY` and `REMOTE_HOST` so the script can pull the latest images and run `docker-compose` on the server.
5. **Post‑Deploy**
   - Optionally run database migrations and verify the service is healthy (e.g., `docker-compose exec zammad rails r ...`).

## Jenkins Credentials

| ID                                   | Purpose                                    |
|--------------------------------------|--------------------------------------------|
| `github-credentials`                 | SSH key used for repo checkout             |
| `dockerhub-credentials`              | Docker Hub username/password               |
| `docker-registry`                    | Docker registry namespace (e.g., `nosayme`)|
| `ssh-remote-server-hostinger-deploy` | Root SSH key to access VPS                 |
| `remote-hostinger-deploy-ip`         | Hostinger server IP address                |
| `remote-user`                        | Linux user for remote Docker commands      |

## Remote Deployment Architecture

1. Jenkins pulls the repository and builds Docker images.
2. Images are pushed to Docker Hub under the namespace defined by `docker-registry`.
3. Jenkins connects to the Hostinger VPS over SSH and executes `deploy-script.sh`.
4. The script sets up directories, installs Docker/Compose if missing, then pulls and runs the stack defined in `docker-compose.yaml`.

```
GitHub → Jenkins → Docker Hub → Hostinger VPS
```

## Running or Modifying the Pipeline

- Jenkins automatically triggers on repository updates (or manual run via UI).
- To modify pipeline logic, edit the `Jenkinsfile` and commit changes.
- Environment variables should be defined in `.env` (or `.env.example` as a template) and injected through Jenkins or the deploy script.
- To re-run the pipeline for troubleshooting, trigger a new build in Jenkins.

## Rotating Docker Hub Credentials

1. Generate new Docker Hub credentials.
2. Update the Jenkins credential named `dockerhub-credentials` with the new username and password.
3. Rerun the pipeline to verify Docker authentication succeeds.

