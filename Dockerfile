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
    novnc \
    websockify \
    curl \
    wget \
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
    pipx install mcp-proxy && \
    ln -s /root/.local/bin/mcp-proxy /usr/local/bin/mcp-proxy

### Cleanup
RUN apt-get autoremove -y && apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* /var/tmp/*

### Copy supervisord config
COPY agent/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

### Create Chrome user data directory (mountable)
RUN mkdir -p /home/rcm/chrome && chown rcm:rcm /home/rcm/chrome

### Create log directories
RUN mkdir -p /var/log/supervisor

### 6080 = noVNC, 3000 = MCP proxy (HTTP/SSE)
EXPOSE 6080 3000

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
