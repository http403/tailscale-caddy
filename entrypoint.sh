#!/bin/sh

set -eux

tailscaled --tun=userspace-networking --statedir=/config/tailscale &
tailscale up --authkey=$TS_AUTH_KEY

tailscale serve / proxy ${TS_PORT:-80}

caddy run \
        --config /etc/caddy/Caddyfile \
        --adapter caddyfile