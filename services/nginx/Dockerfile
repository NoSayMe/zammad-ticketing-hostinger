# Nginx reverse proxy Dockerfile
FROM nginx:alpine

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY nginx/default.http.conf.template /etc/nginx/conf.d/default.http.conf.template
COPY nginx/html /usr/share/nginx/html
COPY nginx/docker-entrypoint.sh /docker-entrypoint.sh
COPY common/ensure-config.sh /usr/local/bin/ensure-config.sh
RUN chmod +x /usr/local/bin/ensure-config.sh /docker-entrypoint.sh

VOLUME ["/var/www/certbot", "/etc/letsencrypt"]

ENTRYPOINT ["/docker-entrypoint.sh"]
