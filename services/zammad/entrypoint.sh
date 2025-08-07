#!/bin/sh
set -e

# Ensure database.yml ownership so Zammad's startup check passes
if [ -f /opt/zammad/config/database.yml ]; then
    chown root:root /opt/zammad/config/database.yml 2>/dev/null || true
fi

exec "$@"
