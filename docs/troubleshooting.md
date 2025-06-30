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
