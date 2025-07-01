# Nginx reverse proxy Dockerfile
FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf.template /etc/nginx/conf.d/default.conf.template
COPY default.http.conf.template /etc/nginx/conf.d/default.http.conf.template
COPY html /usr/share/nginx/html
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["/var/www/certbot", "/etc/letsencrypt"]

ENTRYPOINT ["/docker-entrypoint.sh"]
