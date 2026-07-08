FROM Debian:bulleye


RUN apt update && apt install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*
RUN chmod +x


EXPOSE 3306
ENTRYPOINT
