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

## Database connection errors
- Verify the `postgres` container is running and reachable.
- Confirm credentials in `.env` match the database environment variables.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [First Run Checks](first-run-checks.md) | [Deployment](deployment.md)
