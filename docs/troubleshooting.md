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

## Database connection errors
- Verify the `postgres` container is running and reachable.
- Confirm credentials in `.env` match the database environment variables.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [First Run Checks](first-run-checks.md) | [Deployment](deployment.md)
