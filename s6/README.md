# Caddy via Tailscale using s6

This uses s6-overlay as an init system for the container and run `tailscaled` as a service rather uisng some bash tricks. This gives more stability and fault tolerance as now s6 is actively managing `tailscaled` and will restart it if ever gone down.

Be aware that the container will start even if `TS_AUTH_KEY` either missing or invalid. It will gives a log line about this, and nothing more.
