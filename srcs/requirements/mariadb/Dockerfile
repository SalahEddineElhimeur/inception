FROM debian:bullseye


RUN apt-get update && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*  \
    && rm -rf /var/lib/mysql/*
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/db-init.sh /usr/local/bin/db-init.sh
RUN chmod +x /usr/local/bin/db-init.sh

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/db-init.sh"]
