#!/bin/bash
set -euo pipefail
exec > >(tee -i deploy.log) 2>&1

# Usage: deploy-script.sh <docker_registry> <remote_ip> <remote_domain> [certbot_email]
DOCKER_REGISTRY=${1:-""}
REMOTE_HOST=${2:-"localhost"}
REMOTE_DOMAIN=${3:-"localhost"}
CERTBOT_EMAIL_ARG=${4:-""}

# Compose project name controls Docker volume prefixes
COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-$(basename "$PWD")}
export COMPOSE_PROJECT_NAME

# Derived volume names used by certbot and nginx
CERTBOT_WEBROOT_VOLUME="${COMPOSE_PROJECT_NAME}_certbot_webroot"
CERTBOT_CONF_VOLUME="${COMPOSE_PROJECT_NAME}_certbot_conf"

echo "🚀 Deploying Zammad stack (registry: $DOCKER_REGISTRY, host: $REMOTE_HOST, domain: $REMOTE_DOMAIN)"

# Install Docker if not present
if ! command -v docker &>/dev/null; then
    echo "📦 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo systemctl enable --now docker
fi

# Install Docker Compose if not present
if ! command -v docker-compose &>/dev/null; then
    echo "📦 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Ensure named Docker volumes exist with project prefix
for volume in zammad_data postgres_data elastic_data certbot_conf certbot_webroot; do
    docker volume create "${COMPOSE_PROJECT_NAME}_${volume}" >/dev/null || true
done

# Replace registry placeholder if present
if grep -q "\${DOCKER_REGISTRY}" docker-compose.yaml 2>/dev/null; then
    sed -i "s|\${DOCKER_REGISTRY}|$DOCKER_REGISTRY|g" docker-compose.yaml
fi

# Replace domain placeholder if present
if grep -q "\${REMOTE_DOMAIN}" docker-compose.yaml 2>/dev/null; then
    sed -i "s|\${REMOTE_DOMAIN}|$REMOTE_DOMAIN|g" docker-compose.yaml
fi

if grep -q "\${REMOTE_DOMAIN}" .env 2>/dev/null; then
    sed -i "s|\${REMOTE_DOMAIN}|$REMOTE_DOMAIN|g" .env
fi

# Determine email for Certbot
if [ -n "$CERTBOT_EMAIL_ARG" ]; then
    CERTBOT_EMAIL="$CERTBOT_EMAIL_ARG"
elif [ -n "${CERTBOT_EMAIL:-}" ]; then
    : # value already set
else
    if [ -f .env ]; then
        CERTBOT_EMAIL=$(grep '^CERTBOT_EMAIL=' .env | cut -d '=' -f2 || true)
    else
        echo "❌ CERTBOT_EMAIL not set. Provide as argument or via CERTBOT_EMAIL env variable."
        exit 1
    fi
fi

# Bootstrap certificate if it doesn't already exist
CERT_PATH=$(docker volume inspect "$CERTBOT_CONF_VOLUME" -f '{{ .Mountpoint }}')
if [ ! -d "$CERT_PATH/live/$REMOTE_DOMAIN" ]; then
    echo "📡 Starting nginx for ACME challenge..."
    docker-compose up -d nginx

    echo "🔍 Pre-validating challenge path..."
    docker run --rm -v "$CERTBOT_WEBROOT_VOLUME":/var/www/certbot busybox sh -c 'echo ok > /var/www/certbot/.well-known-check.txt'
    for i in $(seq 1 10); do
        if curl -fs "http://$REMOTE_DOMAIN/.well-known/acme-challenge/.well-known-check.txt" >/dev/null; then
            echo "✅ Challenge directory reachable"
            break
        fi
        echo "Waiting for nginx to serve challenge path ($i/10)..."
        sleep 3
    done
    if ! curl -fs "http://$REMOTE_DOMAIN/.well-known/acme-challenge/.well-known-check.txt" >/dev/null; then
        echo "❌ Challenge directory not reachable after waiting"
        docker-compose logs nginx | tail -n 20
        exit 1
    fi
    docker run --rm -v "$CERTBOT_WEBROOT_VOLUME":/var/www/certbot busybox rm /var/www/certbot/.well-known-check.txt

    echo "🔐 Requesting initial certificate..."
    docker run --rm \
      -v "$CERTBOT_CONF_VOLUME":/etc/letsencrypt \
      -v "$CERTBOT_WEBROOT_VOLUME":/var/www/certbot \
      certbot/certbot certonly --webroot \
      -w /var/www/certbot \
      -d "$REMOTE_DOMAIN" \
      --non-interactive \
      --agree-tos \
      --email "$CERTBOT_EMAIL" \
      --no-eff-email

    echo "🔄 Restarting nginx to apply HTTPS config"
    docker-compose restart nginx
fi

# Pull and run containers
docker-compose pull
docker-compose up -d

docker-compose ps

echo "✅ Deployment complete"
