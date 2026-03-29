#!/bin/bash
# Default TLS_DOMAIN to :80 when empty/unset so Caddy listens on plain HTTP

export TLS_DOMAIN="${TLS_DOMAIN:-:80}"
exec "$@"
