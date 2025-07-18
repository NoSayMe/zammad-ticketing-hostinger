[← Back to Main README](README/index.md)

> **Prerequisite:** Ensure your domain's DNS A record points to the VPS IP and ports 80/443 are reachable.

# Certbot Setup and ACME HTTP-01 Explained

Certbot obtains TLS certificates from Let's Encrypt. This stack uses the **webroot** challenge method. Certbot writes temporary files to a shared directory which NGINX exposes at `http://<domain>/.well-known/acme-challenge/`.

## How HTTP-01 Validation Works

1. Certbot creates a unique challenge file inside `/var/www/certbot`.
2. Let's Encrypt downloads this file over HTTP to verify domain ownership.
3. When the file is reachable, Certbot receives the signed certificate.

## Required NGINX Configuration

NGINX must serve the challenge directory without redirecting it to HTTPS:

```nginx
location /.well-known/acme-challenge/ {
    alias /var/www/certbot/.well-known/acme-challenge/;
}
```

This block should appear **before** any other redirect rules. The NGINX and Certbot containers both mount the same directory:

```yaml
volumes:
  - certbot_webroot:/var/www/certbot
```

> **Note:** The `.well-known/acme-challenge/` path is mapped via `alias` in
> NGINX. You will not see that directory inside the container. Files created in
> the `certbot_webroot` volume appear directly under `/var/www/certbot/`.

## Cloudflare Proxy Considerations

If your DNS uses Cloudflare, disable the orange cloud (HTTP proxy) during certificate requests. The challenge files must be fetched directly from the server.

## Testing Before Requesting a Certificate

Create a test file in the shared volume and verify it from outside the server:

```bash
docker run --rm -v certbot_webroot:/var/www/certbot busybox sh -c 'echo hello > /var/www/certbot/test.txt'
curl http://<domain>/.well-known/acme-challenge/test.txt
```

A successful response confirms that DNS and NGINX are correctly configured.

---
🔗 Back to [Main README](README/index.md)
📚 See also: [certbot.md](certbot.md) | [First Run](first-run.md)
