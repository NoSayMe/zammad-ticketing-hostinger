[← Back to Main README](README/index.md)

> **Prerequisite:** Ensure the [Requirements & Prerequisites](README/index.md#-requirements--prerequisites) are in place.

# Homepage

The static landing page is served by the NGINX container. It resides at `services/nginx/html/index.html` and is copied into the image during the Docker build.

Links are provided to:
- `/zammad` – the Zammad web interface
- `/wiki` – future documentation site
- `/status` – placeholder for health checks

Edit `index.html` and rebuild the `nginx` service to change the content.

---
🔗 Back to [Main README](README/index.md)  
📚 See also: [Branding](branding.md) | [Deployment](deployment.md)
