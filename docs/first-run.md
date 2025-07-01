[← Back to Main README](../README.md)

> **Prerequisite:** Ensure the [Requirements & Prerequisites](../README.md#-requirements--prerequisites) are met.

# First Run Guide

This guide collects notes and fixes for your very first deployment. Follow the [Deployment guide](deployment.md) then review the checks below.

## 🐛 Common Errors During First Run

### Certbot Fails with RecursionError

**Symptoms:**
- Jenkins log shows: `RecursionError: maximum recursion depth exceeded`
- Certbot fails to issue the initial certificate
- May appear with `Skipped user interaction` warning

**Cause:**
- Certbot expected a TTY but wasn't passed `--non-interactive`
- Misconfigured `--webroot-path` or recursive mount volume

**Resolution:**
- Always include `--non-interactive --agree-tos --email "$CERTBOT_EMAIL"`
- Use `--webroot` and confirm the path exists in both NGINX and Certbot containers.
- The `$CERTBOT_EMAIL` value comes from the Jenkins secret `certbot-email`.
- Run manually if needed:
  ```bash
  docker run --rm \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /var/www/certbot:/var/www/certbot \
    certbot/certbot certonly --webroot \
    --webroot-path /var/www/certbot \
    -d example.com \
    --non-interactive --agree-tos --email admin@example.com
  ```

**Troubleshooting:**
- Run with `-v` for verbose logging
- Check logs:
  ```bash
  cat /var/log/letsencrypt/letsencrypt.log
  docker logs certbot
  ```

---
🔗 Back to [Main README](../README.md)
📚 See also: [First Run Checks](first-run-checks.md) | [Deployment](deployment.md) | [Troubleshooting](troubleshooting.md)
