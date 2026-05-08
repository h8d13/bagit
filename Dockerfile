FROM alpine:latest

RUN apk add --no-cache git openssh-server python3 \
    && adduser -D git \
    && passwd -u git \
    && mkdir -p /home/git/.ssh /data \
    && ln -s /data /home/git/.bgit \
    && chown -R git:git /home/git /data \
    && chmod 755 /data

COPY bgit-jail /usr/local/bin/
RUN chmod +x /usr/local/bin/bgit-jail

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME /data
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
