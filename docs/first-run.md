[← Back to Main README](../README.md)

> **Prerequisite:** Ensure the [Requirements & Prerequisites](../README.md#-requirements--prerequisites) are met.

# First Run Guide

This guide collects notes and fixes for your very first deployment. Follow the [Deployment guide](deployment.md) then review the checks below.

## 🔐 Jenkins SSH Setup on Host Machine

To allow the pipeline's `ssh` and `scp` steps to run correctly, the Jenkins host must have its SSH directory prepared **before the first build**:

```bash
# Create .ssh directory if it doesn't exist
sudo mkdir -p /var/lib/jenkins/.ssh
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh
sudo chmod 700 /var/lib/jenkins/.ssh

# Create empty known_hosts file
sudo touch /var/lib/jenkins/.ssh/known_hosts
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/known_hosts
sudo chmod 644 /var/lib/jenkins/.ssh/known_hosts

# Restart Jenkins after change
sudo systemctl restart jenkins
```

Perform this step only once as part of preparing the Jenkins node. It ensures SSH based deployments succeed and prevents `Permission denied` or `Failed to add host to known_hosts` errors.

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

### SSH Known Hosts

**Symptoms:** Jenkins stages using `ssh` or `scp` exit with:
`Failed to add the host to the list of known hosts (/var/lib/jenkins/.ssh/known_hosts)`.

**Resolution:** Ensure the pipeline creates the `known_hosts` file with `ssh-keyscan` before connecting:

```bash
mkdir -p /var/lib/jenkins/.ssh
ssh-keyscan "$REMOTE_HOST" >> /var/lib/jenkins/.ssh/known_hosts
chmod 600 /var/lib/jenkins/.ssh/known_hosts
```

This removes interactive prompts and lets Jenkins connect non‑interactively.

If this step still fails, confirm you've completed the [Jenkins SSH Setup on Host Machine](#-jenkins-ssh-setup-on-host-machine).

## ⚠️ Common Certbot Failures and How to Fix Them

These errors typically appear during the first certificate request. Use the checklist below before re‑running Certbot.

1. **Domain not pointing to the VPS** – verify the DNS `A` record:
   ```bash
   dig +short <domain>
   ```
   The output should be the server's public IPv4.
2. **Challenge path not reachable** – ensure NGINX serves the directory used by Certbot. The deploy script writes a temporary `.well-known-check.txt` file to the `zammad_certbot_webroot` volume and verifies it before requesting a certificate:
   ```bash
   curl http://<domain>/.well-known/acme-challenge/.well-known-check.txt
   docker exec nginx curl -s localhost/.well-known/acme-challenge/.well-known-check.txt
   docker exec certbot ls /var/www/certbot
   # manually create the check file if needed
   docker run --rm -v zammad_certbot_webroot:/var/www/certbot busybox sh -c 'echo ok > /var/www/certbot/.well-known-check.txt'
   docker run --rm -v zammad_certbot_webroot:/var/www/certbot busybox rm /var/www/certbot/.well-known-check.txt
   ```
   All commands must succeed. If they fail, confirm that both containers share the `certbot_webroot` volume.
3. **Cloudflare or firewall interference** – temporarily disable any proxies and open port 80 directly to the server.
4. **NGINX config missing ACME block** – the container entrypoint now injects this block automatically if missing. If you still don't see it in `/etc/nginx/conf.d/default.conf`, add:
```nginx
location /.well-known/acme-challenge/ {
    alias /var/www/certbot/.well-known/acme-challenge/;
}
```
Then reload NGINX with `nginx -t && nginx -s reload`.


If any step fails, fix the issue before launching Certbot again.

---
🔗 Back to [Main README](../README.md)
📚 See also: [First Run Checks](first-run-checks.md) | [Deployment](deployment.md) | [Troubleshooting](troubleshooting.md)
