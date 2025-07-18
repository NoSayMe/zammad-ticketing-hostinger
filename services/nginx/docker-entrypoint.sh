#!/bin/sh
set -e
# substitute domain into config
CERT_PATH="/etc/letsencrypt/live/${REMOTE_DOMAIN}/fullchain.pem"
CONF_DIR="/etc/nginx/conf.d"
CONF_FILE="$CONF_DIR/default.conf"
mkdir -p "$CONF_DIR"

if [ ! -f "$CONF_FILE" ]; then
    if [ -f "$CERT_PATH" ]; then
        /usr/local/bin/ensure-config.sh /etc/nginx/conf.d/default.conf.template "$CONF_FILE" '$REMOTE_DOMAIN'
    else
        echo "Using temporary HTTP config until certificate exists"
        /usr/local/bin/ensure-config.sh /etc/nginx/conf.d/default.http.conf.template "$CONF_FILE" '$REMOTE_DOMAIN'
    fi
else
    echo "Using existing $CONF_FILE"
fi

if ! grep -q '/.well-known/acme-challenge/' "$CONF_FILE"; then
    echo "Injecting ACME challenge block into $CONF_FILE"
    sed -i '/server_name/a\    location /.well-known/acme-challenge/ {\n        alias /var/www/certbot/;\n    }\n' "$CONF_FILE"
fi

nginx -t
exec nginx -g 'daemon off;'
