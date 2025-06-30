# Nginx reverse proxy Dockerfile
FROM nginx:alpine

COPY conf.d /etc/nginx/conf.d
COPY html /usr/share/nginx/html

VOLUME ["/var/www/certbot", "/etc/letsencrypt"]

CMD ["nginx", "-g", "daemon off;"]
