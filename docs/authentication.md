[← Back to Main README](../README.md)

> **Prerequisite:** Ensure the [Requirements & Prerequisites](../README.md#-requirements--prerequisites) are met, particularly Azure tenant admin access.

# Authentication and SSO

Zammad can integrate with Microsoft 365 / Entra ID for single sign-on.

> **⚠️ Sensitive Keys**
> All required keys and secrets for this integration are injected securely via Jenkins and are not stored in this repository.

When implemented, configure the necessary OAuth application in Microsoft 365 and store the credentials in Jenkins. Reference these credential IDs from the pipeline to pass them into the container.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [Deployment](deployment.md) | [CI/CD](ci-cd-pipeline.md) | [Secrets](secrets.md)
