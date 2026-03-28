#### Build Stage — gateway binary ####
FROM golang:1.26 AS builder

WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /bin/remote-chrome-mcp ./cmd/main.go

#### Runtime Stage ####
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

### Create user
RUN userdel -r ubuntu 2>/dev/null || true && \
    useradd -m -u 1000 -s /bin/bash rcm

### Install supervisor and display stack
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    xvfb \
    x11vnc \
    curl \
    ca-certificates \
    gnupg && \
    rm -rf /var/lib/apt/lists/*

### Copy install scripts and install Chromium
COPY agent/install/install_chromium.sh /tmp/install_chromium.sh
RUN bash /tmp/install_chromium.sh && rm /tmp/install_chromium.sh

### Install Node.js (for chrome-devtools-mcp via npx)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

### Install mcp-proxy (Python)
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip pipx && \
    rm -rf /var/lib/apt/lists/* && \
    PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install mcp-proxy

### Cleanup
RUN apt-get autoremove -y && apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* /var/tmp/*

### Install gateway binary
COPY --from=builder /bin/remote-chrome-mcp /usr/local/bin/remote-chrome-mcp

### Copy supervisord config
COPY agent/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

### Create Chrome user data directory (mountable)
RUN mkdir -p /home/rcm/chrome && chown rcm:rcm /home/rcm/chrome

### Create log directories
RUN mkdir -p /var/log/supervisor

### 8080 = gateway (MCP proxy with token auth), 5900 = VNC
EXPOSE 8080 5900

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
