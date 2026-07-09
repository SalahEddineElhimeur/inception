FROM debian:bullseye


RUN apt-get update && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*
COPY conf/my.cnf /etc/mysql/my.cnf
RUN chmod 644 /etc/mysql/my.cnf

COPY tools/db-init.sh /usr/local/bin/db-init.sh
RUN chmod 755 /usr/local/bin/db-init.sh

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/db-init.sh"]
