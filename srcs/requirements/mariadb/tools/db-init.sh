#!/bin/bash

#MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
#1MYSQL_PASSWORD=$(cat /run/secrets/db_password)


MYSQL_ROOT_PASSWORD=password
MYSQL_PASSWORD=password
mkdir -p /var/run/mysqld

chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql


if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    mysqld_safe --skip-networking &


    until mysqladmin ping --silent; do 
        sleep 1
    done

    mysql -u root << EOF
        CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`; 
        CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
        GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
        FLUSH PRIVILEGES;
EOF

    
   # mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

fi

exec mysqld