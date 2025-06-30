# Nginx reverse proxy Dockerfile
FROM nginx:alpine

COPY conf.d /etc/nginx/conf.d

VOLUME ["/var/www/certbot", "/etc/letsencrypt"]

CMD ["nginx", "-g", "daemon off;"]
