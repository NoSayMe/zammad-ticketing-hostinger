# Zammad Service

Zammad provides the ticketing UI and API. The container is built from `services/zammad/Dockerfile` and depends on the `postgres` and `elasticsearch` services.

## Data Volume

- **`zammad_data`** mounted at `/opt/zammad`

This stores all configuration, attachments and application data.

## Verification

After `docker-compose up -d` browse to `https://<your-domain>/zammad` and you should see the setup wizard. You can also run:

```bash
docker-compose logs zammad
```

## Troubleshooting

If the service fails to start:
- Check connectivity to the database and elasticsearch containers.
- Review logs with `docker logs zammad`.
- Ensure permissions on the `zammad_data` volume allow write access.
