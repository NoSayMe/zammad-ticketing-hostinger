# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY . /src
RUN set -eux; \
    if [ -f /src/recipes-frontend/package.json ]; then \
      cp /src/recipes-frontend/package.json /app/package.json; \
      if [ -f /src/recipes-frontend/package-lock.json ]; then cp /src/recipes-frontend/package-lock.json /app/package-lock.json; fi; \
      cp -r /src/recipes-frontend/. /app/; \
    elif [ -f /src/services/recipes-frontend/package.json ]; then \
      cp /src/services/recipes-frontend/package.json /app/package.json; \
      if [ -f /src/services/recipes-frontend/package-lock.json ]; then cp /src/services/recipes-frontend/package-lock.json /app/package-lock.json; fi; \
      cp -r /src/services/recipes-frontend/. /app/; \
    else \
      echo "recipes-frontend not found" >&2; ls -laR /src >&2; exit 1; \
    fi
RUN npm ci --no-audit --no-fund || (npm install --no-audit --no-fund && true)
RUN npm run build

# Serve stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html/recipes
RUN printf 'location /recipes/ { try_files $uri /recipes/index.html; }\n' > /etc/nginx/conf.d/recipes.conf
EXPOSE 80