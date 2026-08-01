FROM debian:bullseye

RUN apt-get update

RUN mkdir -p test
RUN touch ./test/file


ENTRYPOINT ["cat", "/dev/random"]