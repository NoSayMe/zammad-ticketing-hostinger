# PostgreSQL service Dockerfile
FROM postgres:15-alpine

# Set default environment variables
ENV POSTGRES_DB=zammad_production \
    POSTGRES_USER=zammad \
    POSTGRES_PASSWORD=zammad

VOLUME ["/var/lib/postgresql/data"]

CMD ["docker-entrypoint.sh", "postgres"]
