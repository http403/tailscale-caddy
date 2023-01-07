FROM caddy:2.6-builder AS builder

# This build caddy with custom modules
RUN xcaddy build \
        --with github.com/mholt/caddy-webdav

FROM tailscale/tailscale:stable

RUN set -eux; \
        mkdir -p \
                /config/tailscale \
                /config/caddy \
                /data/caddy \
                /etc/caddy \
                /usr/share/caddy \
        ; \
        wget -O /etc/caddy/Caddyfile "https://github.com/caddyserver/dist/raw/8c5fc6fc265c5d8557f17a18b778c398a2c6f27b/config/Caddyfile"; \
        wget -O /usr/share/caddy/index.html "https://github.com/caddyserver/dist/raw/8c5fc6fc265c5d8557f17a18b778c398a2c6f27b/welcome/index.html"

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY ./entrypoint.sh /entrypoint.sh

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

WORKDIR /srv

CMD ["sh", "/entrypoint.sh"]