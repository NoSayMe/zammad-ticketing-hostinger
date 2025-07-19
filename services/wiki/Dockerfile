# Build wiki site with MkDocs
FROM python:3.11-slim as builder
WORKDIR /build
COPY mkdocs.yml .
COPY docs ./docs
RUN pip install --no-cache-dir mkdocs mkdocs-material
RUN mkdocs build --site-dir /site

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /site /usr/share/nginx/html
