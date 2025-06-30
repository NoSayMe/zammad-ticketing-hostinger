You are a DevOps & backend automation agent working in a public open-source GitHub repository.
Your task is to build, configure, and maintain a secure, modular, and CI/CD-enabled deployment of the open-source **Zammad ticketing system**, hosted on a **remote Hostinger VPS** with **SSH root access**, and integrated with **Microsoft 365** services.

## 🌍 Project Context
This is part of a public effort to build an **easy-to-deploy**, **cost-effective**, and **extensible** open-source solution for small and mid-sized businesses. The system is deployed using an **automated Jenkins pipeline** and is designed to support future features like **n8n workflows**, **document automation**, and **AI agent integration**.

---

## 🎯 Objective
Deploy Zammad on a remote VPS (Hostinger) using:
- Docker Compose stack (including Certbot + NGINX)
- Jenkins-based CI/CD pipeline
- Microsoft 365 OAuth2 integration (email, auth)
- Support for custom organizational branding

---

## ⚠️ CI/CD Compatibility

This project already includes a working Jenkins deployment pipeline using:
- `Jenkinsfile`
- `deploy-script.sh`
- `docker-compose.yaml`

✅ **Do not delete or break these files.**  
They are fully integrated into a Jenkins server using credential bindings and remote SSH deployment.

---

## 🔐 Jenkins Global Credentials (used in pipeline)

These are not stored in the repo but must be referenced in the pipeline using Jenkins credential bindings:

- `github-credentials`: SSH key for GitHub access (ID: `<Github account>`)
- `dockerhub-credentials`: DockerHub login (`<username>/****`)
- `ssh-remote-server-hostinger-deploy`: Root SSH key to remote VPS
- `remote-hostinger-deploy-ip`: Remote server IP
- `remote-user`: Remote Linux user
- `docker-registry`: Docker Registry username

---

## 🛠️ Functional Requirements

### 1. Docker-Based Stack (CI/CD Deployment)
- Extend `docker-compose.yaml` to include:
  - `zammad`, `postgresql`, `elasticsearch`, `nginx`, `certbot`
- Use `.env` for secrets and config (e.g., email, domain, OAuth)
- Set up persistent volumes for all data
- ✅ `docs/deployment.md`

### 2. HTTPS with Certbot + NGINX
- Fully containerized Certbot/NGINX solution
- Auto-renew certs using shared volumes or cronjob
- ✅ `docs/nginx-certbot.md`

### 3. Microsoft 365 Integration
- Email: Shared mailbox for intake (OAuth2)
- SMTP: Send via Microsoft 365 (OAuth2)
- ✅ `docs/email-integration.md`

### 4. Authentication (LDAP / Entra ID)
- Use Microsoft Entra ID via OAuth2/SAML
- Fallback LDAP config if needed
- ✅ `docs/authentication.md`

### 5. System Setup
- Use CLI for first admin (`zammad run rake zammad:make_admin`)
- Set up groups, notifications, SLAs
- ✅ `docs/system-setup.md`

### 6. MS Teams / Power Automate
- Add webhooks to notify ticket events
- Provide sample Power Automate flows
- ✅ `docs/integrations.md`

### 7. SharePoint (Optional)
- Allow saving attachments via Power Automate
- ✅ `docs/integrations.md`

### 8. CI/CD Maintenance
- Continue using `Jenkinsfile` and `deploy-script.sh`
- Jenkins must:
  - Pull latest Zammad images
  - Run DB migrations
  - Restart services
  - Validate HTTPS
- ✅ `docs/maintenance.md`

---

## 🎨 Organizational Branding
Support customization for internal use or external-facing clients:
- Logo and favicon overrides
- Custom email templates
- Optional login message
- ✅ `docs/branding.md`

---

## 📏 Constraints
- Do not modify Zammad’s core application code
- Use only environment variables, volumes, and REST API for customization
- Secure all credentials via `.env` + Jenkins credentials
- Use best practices for log security and deployment hygiene
