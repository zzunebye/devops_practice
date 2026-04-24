FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    procps \
    bc \
    bsdmainutils \
    && rm -rf /var/lib/apt/lists/*

COPY server-stats.sh /server-stats.sh

RUN chmod +x /server-stats.sh

CMD ["/server-stats.sh"]