#!/bin/sh
set -e
# substitute domain into config
CERT_PATH="/etc/letsencrypt/live/${REMOTE_DOMAIN}/fullchain.pem"
if [ -f "$CERT_PATH" ]; then
    envsubst '$REMOTE_DOMAIN' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
else
    echo "Using temporary HTTP config until certificate exists"
    envsubst '$REMOTE_DOMAIN' < /etc/nginx/nginx.http.conf.template > /etc/nginx/nginx.conf
fi
exec nginx -g 'daemon off;'
