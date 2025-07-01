#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <domain> <email>"
    exit 1
fi

DOMAIN="$1"
EMAIL="$2"

docker run --rm -it \
  -v certbot_conf:/etc/letsencrypt \
  -v certbot_webroot:/var/www/certbot \
  certbot/certbot certonly --webroot \
  --webroot-path /var/www/certbot \
  -d "$DOMAIN" \
  --email "$EMAIL" \
  --agree-tos \
  --no-eff-email \
  --debug-challenges \
  --dry-run -v
