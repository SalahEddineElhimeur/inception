FROM debian:bullseye


# 1. Install system tools and explicit PHP 7.4 packages
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

# 2. Download and install WP-CLI globally using the correct full URL
RUN wget raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

    
COPY conf/www.cnf /etc/php/7.4/fpm/pool.d/

COPY tools/wp_init.sh /usr/local/bin/wp_init.sh
RUN chmod +x /usr/local/bin/wp_init.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/wp_init.sh"]
