FROM debian:bullseye

RUN apt-get update && apt-get install -y wget

RUN wget -O /usr/local/bin/cadvisor \
    https://github.com/google/cadvisor/releases/download/v0.47.2/cadvisor-v0.47.2-linux-amd64 \
    && chmod +x /usr/local/bin/cadvisor

EXPOSE 8082

ENTRYPOINT ["/usr/local/bin/cadvisor" , "-port=8082"]