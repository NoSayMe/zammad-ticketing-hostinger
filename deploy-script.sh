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

# Helper to ensure a key=value exists/updated in .env
ensure_env() {
  local key="$1"; shift
  local value="$1"; shift || true
  if [ -f .env ]; then
    if grep -q "^${key}=" .env; then
      sed -i "s|^${key}=.*|${key}=${value}|" .env
    else
      echo "${key}=${value}" >> .env
    fi
  else
    echo "${key}=${value}" > .env
  fi
}

# Write critical runtime values to .env so compose resolves ${VAR:-default}
if [ -n "$DOCKER_REGISTRY" ]; then
  ensure_env DOCKER_REGISTRY "$DOCKER_REGISTRY"
fi
ensure_env REMOTE_DOMAIN "$REMOTE_DOMAIN"

# Determine email for Certbot
if [ -n "$CERTBOT_EMAIL_ARG" ]; then
    CERTBOT_EMAIL="$CERTBOT_EMAIL_ARG"
elif [ -n "${CERTBOT_EMAIL:-}" ]; then
    : # value already set
else
    if [ -f .env ]; then
        CERTBOT_EMAIL=$(grep '^CERTBOT_EMAIL=' .env | cut -d '=' -f2 || true)
    fi
fi

# If we have a certbot email now, persist it to .env (optional)
if [ -n "${CERTBOT_EMAIL:-}" ]; then
  ensure_env CERTBOT_EMAIL "$CERTBOT_EMAIL"
fi

# Bootstrap certificate if it doesn't already exist
CERT_PATH=$(docker volume inspect "$CERTBOT_CONF_VOLUME" -f '{{ .Mountpoint }}')
if [ ! -d "$CERT_PATH/live/$REMOTE_DOMAIN" ]; then
    echo "📡 Starting nginx for ACME challenge..."
    docker-compose up -d nginx

    echo "🔍 Pre-validating challenge path..."
    docker run --rm -v "$CERTBOT_WEBROOT_VOLUME":/var/www/certbot busybox \
      sh -c 'mkdir -p /var/www/certbot/.well-known/acme-challenge && \
      echo ok > /var/www/certbot/.well-known/acme-challenge/.well-known-check.txt'
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
    docker run --rm -v "$CERTBOT_WEBROOT_VOLUME":/var/www/certbot busybox rm /var/www/certbot/.well-known/acme-challenge/.well-known-check.txt

    if [ -n "${CERTBOT_EMAIL:-}" ]; then
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
    else
      echo "ℹ️ Skipping initial certificate request (no CERTBOT_EMAIL provided)"
    fi
fi

# Pull and run containers
docker-compose pull || true
docker-compose up -d

docker-compose ps

echo "✅ Deployment complete"
