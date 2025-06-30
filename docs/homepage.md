# Homepage

The static landing page is served by the NGINX container. It resides at `services/nginx/html/index.html` and is copied into the image during the Docker build.

Links are provided to:
- `/zammad` – the Zammad web interface
- `/wiki` – future documentation site
- `/status` – placeholder for health checks

Edit `index.html` and rebuild the `nginx` service to change the content.
