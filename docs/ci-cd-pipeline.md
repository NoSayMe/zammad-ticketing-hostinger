[← Back to Main README](../README.md)

> **Prerequisite:** Ensure the [Requirements & Prerequisites](../README.md#-requirements--prerequisites) are satisfied. Jenkins must already be installed.

# Jenkins CI/CD Pipeline

This document explains how the Jenkins pipeline deploys the Zammad stack to an Ubuntu 24.04 LTS server. It covers job creation, GitHub webhook configuration, credential mapping, stage explanations, and basic troubleshooting.

## 1. Jenkins Pipeline Job Setup

1. In Jenkins select **Create New Item** and choose **Pipeline**. Name it `zammad-hostinger`.
2. Under **Build Triggers** check **GitHub hook trigger for GITScm polling** so pushes from GitHub start the job automatically.
3. In the **Pipeline** section choose **Pipeline script from SCM** and configure:
   - **SCM**: Git
   - **Repository URL**: `https://github.com/NoSayMe/zammad-ticketing-hostinger.git`
   - **Credentials**: select the stored SSH key credential `github-credentials`
   - **Branch Specifier**: `*/main`
   - **Script Path**: `Jenkinsfile`
4. Save the job. Jenkins is now ready to run when webhooks arrive or when manually triggered.

## 2. GitHub Webhook

From the GitHub repository settings go to **Webhooks** and create a new webhook with:

- **Payload URL**: `http://<jenkins-ip>:<port>/github-webhook/`
- **Content type**: `application/x-www-form-urlencoded`
- **Events**: choose **Just the push event**
- **Active**: enabled

This is what allows Jenkins to start the pipeline whenever changes are pushed to `main`.

## 3. Credential Mapping

The following Jenkins credentials are referenced in the pipeline and should be created from **Manage Jenkins → Credentials**:

| Jenkins ID                              | Usage       |
|-----------------------------------------|-------------|
| `github-credentials`                    | SSH key used to pull the repository |
| `dockerhub-credentials`                 | Docker Hub login for pushing images |
| `docker-registry`                       | Docker Hub namespace/registry |
| `ssh-remote-server-hostinger-deploy`    | Private key for remote VPS |
| `remote-hostinger-deploy-ip`            | IP address of the Ubuntu server |
| `remote-hostinger-domain`               | Domain name used for production deployment of Zammad |
| `remote-user`                           | Remote Linux user (usually `root`) |

## 4. Jenkinsfile Stages

The `Jenkinsfile` in the repository performs these steps:

1. **Checkout** – `checkout scm` fetches the latest commit.
2. **Build Images** – Optional stage that looks for a `services/` directory and builds any Dockerfiles it finds. Because the project currently only uses the official Zammad image, this stage is skipped until custom services are added.
3. **Push to DockerHub** – If images were built, they are pushed using the credentials defined by `docker-registry` and `dockerhub-credentials`.
4. **Deploy to Remote Server** – Copies `docker-compose.yaml`, `.env`, and `deploy-script.sh` to `/opt/zammad` on the VPS and runs the script. The script installs Docker/Compose if needed, pulls the latest Zammad stack, and starts the services with `docker-compose up -d`.
5. **Post Actions** – Local Docker images are pruned to keep the Jenkins host clean.

## 5. Example Output

A successful run looks similar to:

```
📥 Checking out repository...
🏗️ Building Docker images (if any)...
📤 Pushing Docker images (if any)...
🚀 Deploying to Ubuntu server...
[Remote] docker-compose up -d
📊 Container status shown
✅ Deployment complete
```

## 6. Troubleshooting

**Webhook not triggering**
- Ensure the webhook URL is reachable from GitHub. Check Jenkins logs under **Manage Jenkins → System Log** for incoming hooks.
- Verify the job is configured with the GitHub trigger and that your Jenkins URL is correct.

**Permission denied during SSH**
- Confirm the credential `ssh-remote-server-hostinger-deploy` contains a valid private key and that the public key is in `~/.ssh/authorized_keys` on the VPS.

**Docker push fails**
- Check that the credentials `dockerhub-credentials` are correct and that the Jenkins server has outbound internet access.

**Images not building**
- The build stage only runs if a `services/` directory with Dockerfiles exists. If no custom services are needed you will only see pull and deploy steps.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [Deployment](deployment.md) | [Certbot](certbot.md) | [Secrets](secrets.md)
