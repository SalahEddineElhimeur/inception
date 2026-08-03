FROM debian:bullseye

RUN apt-get update && apt-get insatll -y vsftp \
        && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp-start.sh /usr/local/bin/ftp-start.sh
RUN chmod +x /usr/local/bin/ftp-start.sh

EXPOSE 21 

ENTRYPOINT ["/usr/local/bin/ftp-start.sh"]