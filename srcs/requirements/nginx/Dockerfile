FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/CN=sel-hime.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY /tools/nginx-init.sh /usr/local/bin/nginx-init.sh
RUN chmod +x /usr/local/bin/nginx-init.sh
EXPOSE 443

ENTRYPOINT  ["/usr/local/bin/nginx-init.sh"]
