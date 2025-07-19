# Zammad service Dockerfile
FROM zammad/zammad:latest

# Expose default ports
EXPOSE 3000 6042

VOLUME ["/opt/zammad"]

# wrapper ensures critical configs are owned by root before starting
COPY zammad/entrypoint.sh /usr/local/bin/entrypoint.sh

# Ensure the script is executable. The base image defaults to a non-root user,
# so temporarily switch to root for the permission change.
USER root
RUN chmod +x /usr/local/bin/entrypoint.sh
USER zammad

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/docker-entrypoint.sh"]
