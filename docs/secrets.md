[← Back to Main README](../README.md)

# Jenkins Secrets Index

The following credential IDs are referenced by the deployment pipeline. Values are stored only in Jenkins and never in this repository.

| Jenkins ID                              | Purpose |
|-----------------------------------------|---------|
| `github-credentials`                    | SSH key used to pull the repository |
| `dockerhub-credentials`                 | DockerHub login for pushing images |
| `docker-registry`                       | Docker Hub namespace/registry |
| `ssh-remote-server-hostinger-deploy`    | Private key for remote VPS |
| `remote-hostinger-deploy-ip`            | IP address of the Hostinger server |
| `remote-user`                           | Remote Linux user |
| `remote-hostinger-domain`               | Domain name used for deployment |
| `certbot-email`                         | Email for Let's Encrypt registration |
| `m365-tenant-id`                        | Microsoft 365 tenant ID |
| `m365-client-id`                        | Microsoft 365 application ID |
| `m365-client-secret`                    | Microsoft 365 application secret |
| `m365-smtp-user`                        | SMTP user account |
| `m365-smtp-password`                    | SMTP password/token |
| `m365-shared-mailbox`                   | Shared mailbox address |

---
🔗 Back to [Main README](../README.md)  
📚 See also: [CI/CD](ci-cd-pipeline.md) | [Deployment](deployment.md)
