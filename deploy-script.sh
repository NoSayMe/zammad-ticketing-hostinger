#!/bin/bash
set -euo pipefail

# Example deployment script
# Expect environment variables for remote host and user

ssh "$remote_user@$remote_host" <<'REMOTE'
  cd /opt/zammad
  docker-compose pull
  docker-compose up -d
REMOTE
