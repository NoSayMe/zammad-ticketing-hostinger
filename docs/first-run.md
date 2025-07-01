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

### Certbot Challenge Errors

**Symptoms:** Certbot fails with `Invalid response ... 522` or similar challenge messages.

**Checklist:**
1. Confirm DNS records point to your VPS IPv4:
   ```bash
   dig +short <domain>
   ```
2. Test the challenge path is reachable:
   ```bash
   curl http://<domain>/.well-known/acme-challenge/testfile
   docker exec nginx curl localhost/.well-known/acme-challenge/testfile
   docker exec certbot ls /var/www/certbot
   ```
3. Ensure both NGINX and Certbot mount the same `certbot_www` volume.

If any step fails, adjust DNS or volume mounts before re‑running Certbot.

---
🔗 Back to [Main README](../README.md)
📚 See also: [First Run Checks](first-run-checks.md) | [Deployment](deployment.md) | [Troubleshooting](troubleshooting.md)
