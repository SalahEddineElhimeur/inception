FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx 

COPY conf/website.conf /etc/nginx/conf.d/default.conf

COPY tools/website-init.sh /usr/local/bin/website-init.sh 


COPY tools/website/ /var/www/html/

RUN chmod +x /usr/local/bin/website-init.sh

ENTRYPOINT ["/usr/local/bin/website-init.sh"]