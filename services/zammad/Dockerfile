# Zammad service Dockerfile
FROM zammad/zammad:latest

# Expose default ports
EXPOSE 3000 6042

VOLUME ["/opt/zammad"]

# wrapper ensures critical configs are owned by root before starting
COPY zammad/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/docker-entrypoint.sh"]
