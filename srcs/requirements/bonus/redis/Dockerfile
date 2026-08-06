FROM debian:bookworm

RUN apt-get update && apt-get install -y redis-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/redis.config /etc/redis/redis.conf
COPY /tools/redis-init.sh /usr/local/bin/redis-init.sh
RUN chmod +x /usr/local/bin/redis-init.sh
EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/redis-init.sh"]