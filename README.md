# Remote Chrome MCP

A Docker container that gives Claude (or any MCP client) a real headless Chromium browser. Supports token auth, auto HTTPS, VNC, and CJK fonts.

[中文文档](README.zh.md)

## Quick Start

```bash
docker compose build
AUTH_TOKEN=mytoken VNC_PASSWORD=myvnc docker compose up -d

# HTTPS (auto Let's Encrypt)
AUTH_TOKEN=mytoken VNC_PASSWORD=myvnc TLS_DOMAIN=mcp.example.com docker compose up -d
```

## Add to Claude

In Claude settings, add a new MCP connector with the URL:

```
http://your-server.com/mcp?token=AUTH_TOKEN
```

If HTTPS is enabled:

```
https://mcp.example.com/mcp?token=AUTH_TOKEN
```

## Environment Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `AUTH_TOKEN` | Yes | `changeme` | Token for authenticating MCP requests |
| `VNC_PASSWORD` | Yes | `changeme` | Password for VNC access |
| `TLS_DOMAIN` | No | _(empty)_ | Domain name to enable auto HTTPS |

## Ports

| Port | Description |
| --- | --- |
| 80 / 443 | HTTP / HTTPS |
| 5900 | VNC |

## Persistent Data

Docker named volumes keep data across restarts:

- **`chrome-data`** — Chrome user data (cookies, sessions, bookmarks)
- **`caddy-data`** — TLS certificates

To reset: `docker compose down -v`

## VNC Access

Connect a VNC client to `your-server:5900` with `VNC_PASSWORD` to view the browser.
