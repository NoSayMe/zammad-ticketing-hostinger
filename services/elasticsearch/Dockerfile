# Elasticsearch service Dockerfile
FROM elasticsearch:7.17.12

ENV discovery.type=single-node \
    ES_JAVA_OPTS="-Xms512m -Xmx512m"

VOLUME ["/usr/share/elasticsearch/data"]

CMD ["/usr/local/bin/docker-entrypoint.sh"]
