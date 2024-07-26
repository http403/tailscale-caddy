ARG CADDY_BUILDER_HASH=sha256:0e1004d358d34d08880969fa44f625612d155ea7de6efee876d04aaab8fefb5f
ARG GOLANG_HASH=sha256:0d3653dd6f35159ec6e3d10263a42372f6f194c3dea0b35235d72aabde86486e
ARG APLINE_HASH=sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0

FROM caddy@$CADDY_BUILDER_HASH AS caddy

# This build caddy with custom modules
RUN xcaddy build \
    --with github.com/mholt/caddy-webdav

# Building Tailscale from source
FROM golang@$GOLANG_HASH AS tailscale

ARG TAILSCALE_GIT_URL=https://github.com/tailscale/tailscale.git
ARG TAILSCALE_VERSION=v1.70.0

RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build \
    set -eux; \
    apk add --no-cache --no-interactive \
        git \
    ; \
    \
    mkdir -p /usr/src/tailscale; \
    git clone --branch=${TAILSCALE_VERSION} ${TAILSCALE_GIT_URL} /usr/src/tailscale; \
    \
    eval `CGO_ENABLED=0 GOOS=$(go env GOHOSTOS) GOARCH=$(go env GOHOSTARCH) go run -C /usr/src/tailscale ./cmd/mkversion`; \
    tags="ts_omit_aws,ts_omit_bird,ts_omit_tap,ts_omit_kube,ts_omit_completion"; \
    ldflags="-X tailscale.com/version.longStamp=${VERSION_LONG} -X tailscale.com/version.shortStamp=${VERSION_SHORT} -w -s"; \
    \
    go build -C /usr/src/tailscale -tags "$tags" -ldflags "$ldflags" tailscale.com/cmd/tailscale; \
    go build -C /usr/src/tailscale -tags "$tags" -ldflags "$ldflags" tailscale.com/cmd/tailscaled;

# Finalize everything together
FROM alpine@$APLINE_HASH AS release
ARG S6_OVERLAY_VERSION=3.2.0.0

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN set -eux; \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz; \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz; \
    apk add --no-cache --no-interactive \
        execline \
    ;

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

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY --from=tailscale /usr/src/tailscale/tailscale /usr/src/tailscale/tailscaled /usr/bin
COPY ./s6-rc.d/ /etc/s6-overlay/s6-rc.d/   

ENTRYPOINT [ "/init" ]
CMD [ "/usr/bin/caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile" ]
