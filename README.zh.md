# Remote Chrome MCP

Docker 容器，为 Claude（或任何 MCP 客户端）提供远程 Chrome 浏览器。支持 Token 认证、自动 HTTPS、VNC 远程查看及中日韩字体。

[English](README.md)

## 快速开始

```bash
docker compose build
AUTH_TOKEN=mytoken VNC_PASSWORD=myvnc docker compose up -d

# HTTPS（自动 Let's Encrypt 证书）
AUTH_TOKEN=mytoken VNC_PASSWORD=myvnc TLS_DOMAIN=mcp.example.com docker compose up -d
```

## 添加到 Claude

在 Claude 设置中，添加 MCP connector，地址为：

```
http://your-server.com/mcp?token=AUTH_TOKEN
```

如果启用了 HTTPS：

```
https://mcp.example.com/mcp?token=AUTH_TOKEN
```

## 环境变量

| 变量 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `AUTH_TOKEN` | 是 | `changeme` | MCP 请求认证 Token |
| `VNC_PASSWORD` | 是 | `changeme` | VNC 访问密码 |
| `TLS_DOMAIN` | 否 | _(空)_ | 设置域名以启用自动 HTTPS |

## 端口

| 端口 | 说明 |
| --- | --- |
| 80 / 443 | HTTP / HTTPS |
| 5900 | VNC |

## 持久化数据

Docker 命名卷在重启后保留数据：

- **`chrome-data`** — 浏览器数据（Cookie、会话、书签）
- **`caddy-data`** — TLS 证书

重置数据：`docker compose down -v`

## VNC 访问

使用 VNC 客户端连接 `your-server:5900`，密码为 `VNC_PASSWORD`，即可查看浏览器画面。
