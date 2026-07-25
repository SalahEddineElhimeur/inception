#!/bin/bash
set -e

MYSQL_PASSWORD="password"
MYSQL_ROOT_PASSWORD="password2"
MYSQL_DATABASE="table2"
MYSQL_USER="test3"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."

    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    mysqld_safe --user=mysql --skip-networking &
    TEMP_PID=$!

    until mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent; do
        sleep 1
    done

    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    echo "Databases after initialization:"
    mysql -u root -e "SHOW DATABASES;"

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$TEMP_PID"

else
    echo "MariaDB already initialized."
fi

exec mysqld --user=mysql
