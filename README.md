# Caddy over Tailscale

This repository contains an example Docker Compose configuration that serves Caddy over Tailscale using an approximation to sidecar pattern.

This have the benefits of not needing to use a privileged container, mounting TUN device, and using host network mode. The downside will be the need to create a new image.

## Extra Variants

### s6-overlay

Read the [README.md](./s6/README.md) in `s6` directory.

### Environment Variables
- `TS_AUTH_KEY` Your Tailscale auth key, generate one at https://login.tailscale.com/admin/settings/keys
- `TS_PORT` The port Caddy listening at and Tailscale should proxy to. It defaults to 80 if empty.