# Nginx reverse proxy Dockerfile
FROM nginx:alpine

COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY nginx.http.conf.template /etc/nginx/nginx.http.conf.template
COPY html /usr/share/nginx/html
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["/var/www/certbot", "/etc/letsencrypt"]

ENTRYPOINT ["/docker-entrypoint.sh"]
