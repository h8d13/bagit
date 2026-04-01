FROM alpine:latest

RUN apk add --no-cache git openssh-server lighttpd python3 py3-pygments py3-markdown cgit lua5.3 \
    && adduser -D git \
    && passwd -u git \
    && mkdir -p /home/git/.ssh /data \
    && ln -s /data /home/git/.bgit \
    && chown -R git:git /home/git /data

WORKDIR /srv/gid
RUN mkdir cgit && cp /usr/share/webapps/cgit/* cgit/ && rm -f cgit/cgit.js
COPY cgit/cgit-dark.css cgit/markdown.lua cgit/md-handler.cgi cgit/
COPY cgit-lighttpd.conf cgit-serve ./
COPY bgit-jail /usr/local/bin/
RUN chmod +x /usr/local/bin/bgit-jail cgit-serve cgit/md-handler.cgi

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

VOLUME /data
EXPOSE 22 8080
ENTRYPOINT ["/entrypoint.sh"]
