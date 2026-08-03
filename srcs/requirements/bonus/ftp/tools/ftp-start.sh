#!/bin/bash

FTP_PASSWORD=$(cat /run/secrets/ftp_password) 

# Create required vsftpd directory
mkdir -p /var/run/vsftpd/empty

# Create FTP user with home directory pointing to WordPress volume
if ! id -u "${FTP_USER}" &>/dev/null; then
    useradd -m -d /var/www/html -s /bin/bash "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
fi

echo "Starting vsftpd..."
exec vsftpd /etc/vsftpd.conf