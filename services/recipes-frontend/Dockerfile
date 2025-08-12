# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY recipes-frontend/package.json recipes-frontend/package-lock.json* ./
RUN npm install --no-audit --no-fund
COPY recipes-frontend/ ./
RUN npm run build

# Serve stage
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html/recipes
# Serve at /recipes/ path; ensure index fallback for SPA
RUN printf 'location /recipes/ { try_files $uri /recipes/index.html; }\n' > /etc/nginx/conf.d/recipes.conf
EXPOSE 80
