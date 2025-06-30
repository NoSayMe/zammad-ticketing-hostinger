#!/bin/bash
set -euo pipefail

# Usage: deploy-script.sh <docker_registry> <remote_ip> <remote_domain>
DOCKER_REGISTRY=${1:-""}
REMOTE_HOST=${2:-"localhost"}
REMOTE_DOMAIN=${3:-"localhost"}

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

# Create data directories
sudo mkdir -p data/postgres data/elasticsearch data/zammad certs certs-data nginx/conf.d
sudo chown -R "$USER:$USER" data certs certs-data nginx

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

# Extract admin email for Certbot
ADMIN_EMAIL=$(grep '^ADMIN_EMAIL=' .env | cut -d '=' -f2)

# Ensure certificate volumes exist
docker volume create certbot_conf >/dev/null || true
docker volume create certbot_www >/dev/null || true

# Bootstrap certificate if it doesn't already exist
CERT_PATH=$(docker volume inspect certbot_conf -f '{{ .Mountpoint }}')
if [ ! -d "$CERT_PATH/live/$REMOTE_DOMAIN" ]; then
    echo "🔐 Requesting initial certificate..."
    docker run --rm \
      -v certbot_conf:/etc/letsencrypt \
      -v certbot_www:/var/www/certbot \
      certbot/certbot certonly \
      --webroot -w /var/www/certbot \
      --email "$ADMIN_EMAIL" \
      --agree-tos \
      --no-eff-email \
      -d "$REMOTE_DOMAIN"
fi

# Pull and run containers
docker-compose pull
docker-compose up -d

docker-compose ps

echo "✅ Deployment complete"
