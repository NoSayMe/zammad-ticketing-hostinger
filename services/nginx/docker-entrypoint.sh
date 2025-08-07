#!/bin/sh
set -e
# substitute domain into config
CERT_PATH="/etc/letsencrypt/live/${REMOTE_DOMAIN}/fullchain.pem"
CONF_DIR="/etc/nginx/conf.d"
CONF_FILE="$CONF_DIR/default.conf"
mkdir -p "$CONF_DIR"

# Determine certificate presence and current config mode
HAVE_CERT=0
[ -f "$CERT_PATH" ] && HAVE_CERT=1

IS_HTTPS_CONF=0
if [ -f "$CONF_FILE" ] && grep -q 'listen 443' "$CONF_FILE"; then
    IS_HTTPS_CONF=1
fi

# Ensure configuration matches certificate state
if [ "$HAVE_CERT" -eq 1 ] && [ "$IS_HTTPS_CONF" -eq 0 ]; then
    echo "Switching to HTTPS configuration"
    /usr/local/bin/ensure-config.sh /etc/nginx/conf.d/default.conf.template "$CONF_FILE" '$REMOTE_DOMAIN'
elif [ "$HAVE_CERT" -eq 0 ] && [ "$IS_HTTPS_CONF" -eq 1 ]; then
    echo "Certificate absent; switching to HTTP configuration"
    /usr/local/bin/ensure-config.sh /etc/nginx/conf.d/default.http.conf.template "$CONF_FILE" '$REMOTE_DOMAIN'
elif [ ! -f "$CONF_FILE" ]; then
    if [ "$HAVE_CERT" -eq 1 ]; then
        /usr/local/bin/ensure-config.sh /etc/nginx/conf.d/default.conf.template "$CONF_FILE" '$REMOTE_DOMAIN'
    else
        echo "Using temporary HTTP config until certificate exists"
        /usr/local/bin/ensure-config.sh /etc/nginx/conf.d/default.http.conf.template "$CONF_FILE" '$REMOTE_DOMAIN'
    fi
else
    echo "Using existing $CONF_FILE"
fi

# Ensure ACME challenge location exists (idempotent)
if ! grep -q '/.well-known/acme-challenge/' "$CONF_FILE"; then
    echo "Injecting ACME challenge block into $CONF_FILE"
    sed -i '/server_name/a\    location /.well-known/acme-challenge/ {\n        alias /var/www/certbot/.well-known/acme-challenge/;\n    }\n' "$CONF_FILE"
fi

nginx -t
exec nginx -g 'daemon off;'
