# Nginx reverse proxy Dockerfile
FROM nginx:alpine

# Copy entire nginx directory so we can conditionally select files
COPY nginx /tmp/nginx
COPY common/ensure-config.sh /usr/local/bin/ensure-config.sh

RUN chmod +x /usr/local/bin/ensure-config.sh /tmp/nginx/docker-entrypoint.sh \
    && if [ -f /tmp/nginx/nginx.conf ]; then \
         echo "✅ Using provided nginx.conf"; \
         cp /tmp/nginx/nginx.conf /etc/nginx/nginx.conf; \
       else \
         echo "⚠️  nginx.conf not found, using default.conf.template"; \
         cp /tmp/nginx/default.conf.template /etc/nginx/nginx.conf; \
       fi \
    && cp /tmp/nginx/default.conf.template /etc/nginx/conf.d/default.conf.template \
    && cp /tmp/nginx/default.http.conf.template /etc/nginx/conf.d/default.http.conf.template \
    && cp -r /tmp/nginx/html /usr/share/nginx/html \
    && mv /tmp/nginx/docker-entrypoint.sh /docker-entrypoint.sh \
    && chmod +x /docker-entrypoint.sh \
    && rm -rf /tmp/nginx

VOLUME ["/var/www/certbot", "/etc/letsencrypt"]

ENTRYPOINT ["/docker-entrypoint.sh"]
