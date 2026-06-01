FROM alpine:latest

RUN apk add --no-cache git openssh-server \
    && adduser -D -h /data -s /usr/local/bin/bgit-shell git \
    && passwd -u git \
    && echo /usr/local/bin/bgit-shell >> /etc/shells \
    && mkdir -p /data/.ssh \
    && chown -R git:git /data \
    && chmod 700 /data/.ssh \
    && chmod 755 /data

COPY bgit-shell /usr/local/bin/
RUN chmod +x /usr/local/bin/bgit-shell

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME /data
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
