You are contributing to an open-source project designed to create a secure, modular, and easy-to-deploy ticketing and automation platform based on Zammad and Docker. This project is being actively built to serve small to mid-sized organizations and educational purposes.

⚠️ Above all, this project is **documentation-first**.  
Every feature or service must be accompanied by clear, human-readable documentation that explains:
- What it does
- How to install/deploy it
- How to verify it works
- How to troubleshoot it
- (Optionally) How it works internally

This includes Markdown-based files in `/docs`, and optionally a `/wiki` containerized page for UI-based browsing (to be defined).

---

## 🎯 Project Vision

- A **secure**, **cost-effective**, and **scalable** ticketing solution
- Fully deployable via **Jenkins CI/CD pipeline** to a remote **Hostinger VPS**
- All components run in **Docker containers** with isolated roles
- Clean and modular structure: one service = one Dockerfile
- Seamless integration with **Microsoft 365**, **NGINX + Certbot**, and more
- Emphasis on **education**, **documentation**, and **community usability**
- Clear roadmap for future integrations:
  - n8n (workflow automation)
  - AI Agents (via MCP)
  - Structured document handling (PDF/Office parsing)
  - Web-based admin panel (/wiki or /dashboard)

---

## 🛠️ Core Components

You are responsible for creating, containerizing, and documenting the following:

| Component        | Description                                                   |
|------------------|---------------------------------------------------------------|
| `zammad`         | Main ticketing system                                         |
| `postgresql`     | Relational database backend for Zammad                        |
| `elasticsearch`  | Search indexing backend                                       |
| `nginx`          | TLS termination and reverse proxy                             |
| `certbot`        | HTTPS certificate issuance and renewal                        |
| `homepage`       | Simple static `/` HTML landing page with links to tools       |
| `jenkins`        | CI/CD deployment automation                                   |
| `docs/`          | Markdown documentation for each area                          |

---

## 🔁 Pipeline & Credentials

The project is deployed using a **Jenkins-based CI/CD pipeline**, configured to:

- Pull from GitHub via webhook (`main` branch)
- Build Docker images
- Push to DockerHub
- SSH into remote VPS
- Run `deploy-script.sh` to bring up the stack

All sensitive values (IP, SSH key, domain, registry, SMTP) are passed via **Jenkins credential bindings**.

---

## 📚 Documentation Requirements

For every deployed or integrated component, you must:

- Create a dedicated `.md` file under `docs/`
- Clearly explain:
  - What the service/component does
  - How it’s deployed (including Docker, volumes, ports)
  - What to check to confirm it’s working properly
  - What to try if it fails (logs, container health, restart tips)
  - External links to docs, if relevant
- Use real examples, and plain English
- Prefer visual verification (e.g., accessible URL) and CLI checks (`docker ps`, `docker logs`, etc.)

---

## 🌐 (Optional) Containerized Wiki

We plan to host a `/wiki` or `/docs` page accessible via the domain, rendered from the Markdown files in `docs/`.

This may use:
- `docsify`, `mkdocs`, `jekyll`, or other static site generators
- Containerized UI hosted alongside other services

---

## ⚙️ Service Integrity is Mandatory

✅ Every service must include:

- Persistent volume definition and mounting
- Health check and troubleshooting steps in docs
- Instructions for restarting or reconfiguring
- Proper reverse proxy config if accessed over web

---

## ✅ Deliverables Checklist for Each Service

For each new component (Zammad, NGINX, Certbot, etc.), the following must be delivered:

- [ ] `services/<name>/Dockerfile`
- [ ] `docker-compose.yaml` service definition
- [ ] Mounted volumes defined and documented
- [ ] Any configs (e.g., nginx.conf) stored in `services/<name>/`
- [ ] Markdown file under `/docs/<name>.md`
- [ ] Updated homepage `/` index.html with relevant link (if applicable)
- [ ] Working in end-to-end CI/CD deployment

---

## 🔐 Credentials (in Jenkins)

| ID                          | Purpose                         |
|-----------------------------|---------------------------------|
| `github-credentials`        | SSH access to repo              |
| `dockerhub-credentials`     | DockerHub push login            |
| `docker-registry`           | Registry namespace (`nosayme`) |
| `ssh-remote-server-hostinger-deploy` | Root SSH key for VPS |
| `remote-hostinger-deploy-ip`| IP of VPS                       |
| `remote-user`               | User account on VPS             |
| `remote-hostinger-domain`   | Domain pointed to VPS           |

---

## 🚧 Work Strategy

Each step/task (service, feature, integration) is handled as a discrete documented unit.

Work in the following order:
1. Implement functionality
2. Verify service is functional (in container and deployed)
3. Document setup + verification + troubleshooting
4. Commit in small, self-contained steps

---

## ✅ Current Status

- ✅ Jenkins CI/CD pipeline is working
- ✅ Domain name and IP set up as credentials
- ✅ NGINX + `/` homepage serve is functional
- 🔧 Zammad service being containerized
- 🔧 Certbot auto-renew still pending verification
- 🔧 Proper documentation needed for each service

---

Continue with the next step by checking the `/docs` directory and creating/expanding a service if it’s not complete.
