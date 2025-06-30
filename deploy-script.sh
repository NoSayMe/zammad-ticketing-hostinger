#!/bin/bash
set -euo pipefail

# Usage: deploy-script.sh <docker_registry> <remote_ip>
DOCKER_REGISTRY=${1:-""}
REMOTE_HOST=${2:-"localhost"}

echo "🚀 Deploying Zammad stack (registry: $DOCKER_REGISTRY, host: $REMOTE_HOST)"

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

# Pull and run containers
docker-compose pull
docker-compose up -d

docker-compose ps

echo "✅ Deployment complete"
