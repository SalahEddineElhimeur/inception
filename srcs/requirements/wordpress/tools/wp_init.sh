#!/bin/bash

# 1. Force the directory to exist and enter it
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
cd /var/www/html

# 2. Read secrets and wait for MariaDB
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)


until mysqladmin ping -h mariadb --silent; do
    sleep 1
done


if [ ! -f /var/www/html/wp-config.php ]; then
# 3. DOWNLOAD FIRST 🟢 (This puts the WordPress files in /var/www/html)
wp core download --allow-root

# 4. CONFIG SECOND 🟢 (This now succeeds because the files are present)
wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="mariadb" \
    --allow-root

# 6. Complete the WordPress installation automatically
wp core install \
    --url="http://localhost:8080" \
    --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

wp user create \
    "$WP_USER" \
    "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASSWORD" \
    --role=author \
    --allow-root
fi
# 5. Create runtime dir and launch
mkdir -p /var/run/php

echo "Starting PHP-FPM..."
exec php-fpm7.4 -F

echo "Starting PHP built-in web server on port 8080..."
exec php -S 0.0.0.0:8080
