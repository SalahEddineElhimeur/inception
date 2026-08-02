FROM debian:bullseye


RUN apt-get update && apt-get install -y \
    wget \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-cli \
    php7.4-curl \
    php7.4-gd \
    mariadb-client \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    php7.4-intl \
    php7.4-soap \
    && rm -rf /var/lib/apt/lists/*

RUN wget raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

    
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

COPY tools/wp_init.sh /usr/local/bin/wp_init.sh
RUN chmod +x /usr/local/bin/wp_init.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/wp_init.sh"]
