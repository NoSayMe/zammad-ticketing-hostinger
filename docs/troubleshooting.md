[← Back to Main README](../README.md)

> **Prerequisite:** Confirm the [Requirements & Prerequisites](../README.md#-requirements--prerequisites) are met before diagnosing issues.

# Troubleshooting

Below are common issues encountered when deploying the stack.

## Containers fail to start
- Run `docker-compose ps` to see the current state.
- Inspect logs with `docker-compose logs <service>`.

## Certificate issues
- Ensure ports 80 and 443 are reachable from the internet.
- Check the Certbot container logs for renewal failures.
- Confirm the certificate exists with `docker exec certbot certbot certificates`.
- Use `docker exec certbot certbot renew --dry-run` to test renewal.
- If no certificate is found, rerun `./deploy-script.sh` to request one.
- Verify DNS points to your server with `dig +short <domain>`.
- Confirm both `nginx` and `certbot` mount the shared `certbot_webroot` volume.
- Make sure the ACME challenge location uses a trailing slash in the `alias` path:
  ```nginx
  location /.well-known/acme-challenge/ {
      alias /var/www/certbot/.well-known/acme-challenge/;
  }
  ```
  Without the trailing `/` NGINX may look for files in a duplicated
  `.well-known` directory and return `404`.
- Create a test file and fetch it to confirm reachability:
  ```bash
  docker run --rm -v certbot_webroot:/var/www/certbot \
    busybox sh -c 'echo ok > /var/www/certbot/test.txt'
  curl http://<domain>/.well-known/acme-challenge/test.txt
  ```

## Default NGINX page instead of homepage
If navigating to your domain shows the "Welcome to nginx!" page, the base image's
`default.conf` may have overridden the project configuration. Rebuild the `nginx`
service to ensure `/etc/nginx/conf.d/default.conf` is generated from
`default.conf.template`:

```bash
docker-compose build nginx
docker-compose up -d nginx
```

After rebuilding, visiting `http://<domain>` should display the custom
`index.html` included in `services/nginx/html/`.

## NGINX fails with `"host not found in upstream"`
If `docker logs nginx` shows an error like:

```
host not found in upstream "zammad" in /etc/nginx/conf.d/default.conf:27
```

the proxy container cannot resolve the `zammad` hostname during the
initial configuration test. The template now defers DNS resolution by
using a variable in `proxy_pass`:

```nginx
location /zammad/ {
    set $zammad_upstream "zammad:3000";
    proxy_pass http://$zammad_upstream/;
    ...
}
```

Rebuild the `nginx` image and restart the service:

```bash
docker-compose build nginx
docker-compose up -d nginx
```

## Database connection errors
- Verify the `postgres` container is running and reachable.
- Confirm credentials in `.env` match the database environment variables.
- If `psql` reports `role "postgres" does not exist`, connect using the username
  defined by `POSTGRES_USER` (default `zammad`).

## Zammad permission error
If the Zammad container repeatedly restarts and `docker logs zammad` shows:

```
The file /opt/zammad/config/database.yml is not owned by root
```

the volume files have the wrong ownership. Fix it by resetting the owner:

```bash
docker-compose run --rm -u root zammad \
  chown root:root /opt/zammad/config/database.yml
docker-compose restart zammad
```

## Docker DNS failures
If `docker pull` or `docker-compose up` fail with DNS errors like:

```
dial tcp: lookup registry-1.docker.io on 127.0.0.53:53: read: connection refused
```

the host's resolver may be unstable. Configure Docker to use external DNS
servers:

```bash
sudo mkdir -p /etc/docker
printf '{\n  "dns": ["8.8.8.8", "1.1.1.1"]\n}\n' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

Verify with:

```bash
docker pull busybox
docker run --rm busybox nslookup google.com
```

Both commands should succeed without DNS errors.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [First Run Checks](first-run-checks.md) | [Deployment](deployment.md)
