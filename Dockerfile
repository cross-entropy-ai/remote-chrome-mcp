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

### Install Chinese font support
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-noto-cjk \
    fonts-noto-cjk-extra && \
    rm -rf /var/lib/apt/lists/* && \
    fc-cache -fv

### Install Node.js (for chrome-devtools-mcp via npx)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

### Install mcp-proxy (Python)
RUN apt-get update && apt-get install -y --no-install-recommends python3 python3-pip pipx && \
    rm -rf /var/lib/apt/lists/* && \
    PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install mcp-proxy

### Install Caddy
RUN curl -fsSL "https://caddyserver.com/api/download?os=linux&arch=$(dpkg --print-architecture)" -o /usr/local/bin/caddy && \
    chmod +x /usr/local/bin/caddy

### Cleanup
RUN apt-get autoremove -y && apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* /var/tmp/*

### Copy Caddyfile and supervisord config
COPY agent/Caddyfile /etc/caddy/Caddyfile
COPY agent/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

### Create Chrome user data directory (mountable)
RUN mkdir -p /home/rcm/chrome && chown rcm:rcm /home/rcm/chrome

### Create Caddy data/config directories
RUN mkdir -p /data/caddy /config/caddy

### Create log directories
RUN mkdir -p /var/log/supervisor

### 80 = HTTP (or ACME), 443 = HTTPS, 5900 = VNC
EXPOSE 80 443 5900

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
