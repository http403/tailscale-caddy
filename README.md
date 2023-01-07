# Caddy over Tailscale

This repository contains an example Docker Compose configuration that servers Caddy over Tailscale using side car method.

This have the benefits of not needing to use a privileged container, mounting TUN device, and using host network mode. The downside will be the need to create a new image.

### Environment Variables
- `TS_AUTH_KEY` Your Tailscale auth key, generate one at https://login.tailscale.com/admin/settings/keys
- `TS_PORT` The port Caddy listening at. It defaults to 80 if empty.