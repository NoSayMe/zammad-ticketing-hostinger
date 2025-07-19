[← Back to Main README](README/index.md)

> **Prerequisite:** Ensure the [Requirements & Prerequisites](README/index.md#-requirements--prerequisites) are fulfilled before deploying Zammad.

> **⚠️ Sensitive Keys**
> All required keys and secrets for this integration are injected securely via Jenkins and are not stored in this repository.

# Zammad Service

Zammad provides the ticketing UI and API. The container is built from `services/zammad/Dockerfile` and depends on the `postgres` and `elasticsearch` services.

The base image runs as the `zammad` user. When the custom `entrypoint.sh` script
is added, the Dockerfile temporarily switches to `root` to mark the script as
executable and then switches back:

```dockerfile
COPY zammad/entrypoint.sh /usr/local/bin/entrypoint.sh
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER zammad
```

This ensures the script has the right permissions during build without changing
the default runtime user.

## Data Volume

- **`zammad_data`** mounted at `/opt/zammad`

This stores all configuration, attachments and application data.

## Admin User Initialization via Jenkins

The Jenkins pipeline automatically creates the first Zammad admin account after the stack is deployed. The stage uses the credentials `zammad-admin-email` and `zammad-admin-password` which you define in Jenkins. During the pipeline a remote command is executed:

```bash
docker exec zammad zammad run rake "zammad:make_admin[<email>,<password>]"
```

Email and password values come from Jenkins secrets and are **not** printed in the logs. You can update or rotate these credentials in Jenkins without modifying the repository.

### Confirm the Admin User Exists

1. Browse to `https://<your-domain>/zammad` and log in with the injected credentials.
2. Alternatively check via CLI on the server:

   ```bash
   docker exec -it zammad zammad run rails r "p User.find_by(login: '<email>').admin"
   ```

If the command outputs `true`, the account has admin privileges.

### Changing Credentials

Update the Jenkins secrets `zammad-admin-email` and `zammad-admin-password` and re-run the pipeline. The next deployment will recreate the admin account with the new values.

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

---
🔗 Back to [Main README](README/index.md)  
📚 See also: [Deployment](deployment.md) | [First Run Checks](first-run-checks.md)
