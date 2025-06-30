[← Back to Main README](../README.md)

# Troubleshooting

Below are common issues encountered when deploying the stack.

## Containers fail to start
- Run `docker-compose ps` to see the current state.
- Inspect logs with `docker-compose logs <service>`.

## Certificate issues
- Ensure ports 80 and 443 are reachable from the internet.
- Check the Certbot container logs for renewal failures.

## Database connection errors
- Verify the `postgres` container is running and reachable.
- Confirm credentials in `.env` match the database environment variables.

---
🔗 Back to [Main README](../README.md)  
📚 See also: [First Run Checks](first-run-checks.md) | [Deployment](deployment.md)
