#!/bin/bash
set -e

# Create the socket directory if it doesn't exist
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Only initialize on first boot (volume is empty)
if [ ! -d "/var/lib/mysql/mysql" ]; then

    # Initialize the data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB temporarily in the background just to run setup SQL
    mysqld_safe --skip-networking &
    TEMP_PID=$!

    # Wait until MariaDB is actually ready to accept connections
    until mysqladmin ping --silent; do
        sleep 1
    done

    # Create the database, user, and set root password
    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        FLUSH PRIVILEGES;
EOSQL

    # Shut down the temporary instance cleanly
    mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait $TEMP_PID

fi

# Hand off to the real MariaDB process — this becomes PID 1, running in the foreground
exec mysqld_safe --user=mysql