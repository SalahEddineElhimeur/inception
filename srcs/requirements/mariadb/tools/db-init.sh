#!/bin/bash
set -e

MYSQL_PASSWORD=$(cat /run/secrets/db_password) \
    || { echo "Missing secret: /run/secrets/db_password"; exit 1; }

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password) \
    || { echo "Missing secret: /run/secrets/db_root_password"; exit 1; }
mkdir -p /var/run/mysqld
# test 1 to fail mkdir /this/path/does/not/exist/and/fails
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql
# test 2chown -R test:test2 /var/lib/mysql ---->  chown: invalid user: 'test:test2'



if [ ! -d "/var/lib/mysql/mysql" ]; then

    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    #  mysql_install_db --user=doesnotexist --datadir=/var/lib/mysql
    #   mysql_install_db --user=mysql --datadir=/this/path/does/not/exist
    mysqld_safe --skip-networking &
    TEMP_PID=$!

    until mysqladmin ping --silent; do
        sleep 1
    done

    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $TEMP_PID

fi

exec mysqld_safe --user=mysql