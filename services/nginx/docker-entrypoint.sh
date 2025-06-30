#!/bin/sh
set -e
# substitute domain into config
envsubst '$REMOTE_DOMAIN' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
exec nginx -g 'daemon off;'
