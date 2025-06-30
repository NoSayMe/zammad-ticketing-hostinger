# Authentication and SSO

Zammad can integrate with Microsoft 365 / Entra ID for single sign-on.

> **⚠️ Sensitive Keys**  
> All required keys and secrets for this integration are injected securely via Jenkins and are not stored in this repository.

When implemented, configure the necessary OAuth application in Microsoft 365 and store the credentials in Jenkins. Reference these credential IDs from the pipeline to pass them into the container.
