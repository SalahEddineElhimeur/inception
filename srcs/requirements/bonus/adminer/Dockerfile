FROM debian:bullseye

RUN apt-get update &&  apt-get install -y php adminer

COPY tools/adminer-init.sh /usr/local/bin/adminer-init.sh

RUN chmod +x  /usr/local/bin/adminer-init.sh

ENTRYPOINT [ " /usr/local/bin/adminer-init.sh" ]