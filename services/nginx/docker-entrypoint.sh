#!/bin/sh
set -e
# substitute domain into config
CERT_PATH="/etc/letsencrypt/live/${REMOTE_DOMAIN}/fullchain.pem"
CONF_DIR="/etc/nginx/conf.d"
mkdir -p "$CONF_DIR"
if [ -f "$CERT_PATH" ]; then
    envsubst '$REMOTE_DOMAIN' < /etc/nginx/conf.d/default.conf.template > "$CONF_DIR/default.conf"
else
    echo "Using temporary HTTP config until certificate exists"
    envsubst '$REMOTE_DOMAIN' < /etc/nginx/conf.d/default.http.conf.template > "$CONF_DIR/default.conf"
fi
nginx -t
exec nginx -g 'daemon off;'
