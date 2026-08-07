FROM debian:bookworm


RUN apt-get update && apt-get install -y \
    wget \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN wget raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

    
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/wp_init.sh /usr/local/bin/wp_init.sh
RUN chmod +x /usr/local/bin/wp_init.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/wp_init.sh"]
