[← Back to Main README](../README.md)

# Email Integration

This guide explains how Zammad sends and receives email using Microsoft 365.

> **⚠️ Sensitive Keys**
> All required keys and secrets for this integration are injected securely via Jenkins and are not stored in this repository.

Microsoft 365 OAuth2 credentials and SMTP settings are provided via the following Jenkins secrets:

- `m365-tenant-id`
- `m365-client-id`
- `m365-client-secret`
- `m365-smtp-user`
- `m365-smtp-password`
- `m365-shared-mailbox`

Configure these secrets in Jenkins and reference them in the pipeline so the Zammad container can authenticate with Microsoft 365.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [Authentication](authentication.md) | [Deployment](deployment.md) | [Secrets](secrets.md)
