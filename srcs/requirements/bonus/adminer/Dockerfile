FROM debian:bookworm

RUN apt-get update &&  apt-get install -y php adminer \
    && ln -s /usr/share/adminer/adminer.php /var/www/html/index.php

COPY tools/adminer-init.sh /usr/local/bin/adminer-init.sh

RUN chmod +x  /usr/local/bin/adminer-init.sh

ENTRYPOINT ["/usr/local/bin/adminer-init.sh"]