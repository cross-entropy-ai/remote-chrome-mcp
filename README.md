# Remote Chrome MCP

A Docker container that runs a headless Chromium browser and exposes it as an MCP (Model Context Protocol) server over HTTP. Includes token authentication, auto HTTPS via Caddy, VNC access, and CJK font support.

## Architecture

```
Client -> Caddy (:80/:443, token auth) -> mcp-proxy (:3000) -> chrome-devtools-mcp -> Chromium (CDP :9222) -> Xvfb (:99)
                                                                                                                  |
                                                                                                           x11vnc (:5900)
```

## Quick Start

```bash
# Build the image
docker compose build

# Run (HTTP mode)
AUTH_TOKEN=mytoken VNC_PASSWORD=myvnc docker compose up -d

# Run (HTTPS mode, auto Let's Encrypt)
AUTH_TOKEN=mytoken VNC_PASSWORD=myvnc TLS_DOMAIN=mcp.example.com docker compose up -d
```

## Environment Variables

| Variable       | Required | Default     | Description                                                    |
| -------------- | -------- | ----------- | -------------------------------------------------------------- |
| `AUTH_TOKEN`   | Yes      | `changeme`  | Token for authenticating MCP requests (passed as `?token=...`) |
| `VNC_PASSWORD` | Yes      | `changeme`  | Password for VNC access                                        |
| `TLS_DOMAIN`   | No       | _(empty)_   | Set to a domain name to enable auto HTTPS via Let's Encrypt    |

## Ports

| Port | Service                              |
| ---- | ------------------------------------ |
| 80   | HTTP (or ACME challenge when TLS on) |
| 443  | HTTPS (when `TLS_DOMAIN` is set)     |
| 5900 | VNC                                  |

## Persistent Data

The `docker-compose.yaml` uses Docker named volumes for persistence:

- **`chrome-data`** — Chrome user data (cookies, login sessions, bookmarks, extensions)
- **`caddy-data`** — TLS certificates and Caddy state

Data survives container restarts. To reset, run `docker compose down -v`.

## MCP Client Configuration

### HTTP

```json
{
  "mcpServers": {
    "remote-chrome": {
      "type": "streamable-http",
      "url": "http://your-server/?token=mytoken"
    }
  }
}
```

### HTTPS

```json
{
  "mcpServers": {
    "remote-chrome": {
      "type": "streamable-http",
      "url": "https://mcp.example.com/?token=mytoken"
    }
  }
}
```

## VNC Access

Connect a VNC client to `your-server:5900` with the `VNC_PASSWORD` to view and interact with the browser.
