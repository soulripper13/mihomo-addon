ARG BUILD_FROM
FROM $BUILD_FROM

# Install dependencies
RUN apk add --no-cache ca-certificates curl libcap bash jq iptables unzip

# Copy startup script
COPY run.sh /
RUN chmod a+x /run.sh

# Download Mihomo (Clash Meta)
# Use the BUILD_ARCH to download the correct version
ARG BUILD_ARCH
RUN if [ "${BUILD_ARCH}" = "aarch64" ]; then ARCH="arm64"; \
    elif [ "${BUILD_ARCH}" = "amd64" ]; then ARCH="amd64"; \
    elif [ "${BUILD_ARCH}" = "armhf" ]; then ARCH="armv6"; \
    elif [ "${BUILD_ARCH}" = "armv7" ]; then ARCH="armv7"; \
    else ARCH="amd64"; fi \
    && VERSION="v1.18.9" \
    && curl -L -o /tmp/mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/${VERSION}/mihomo-linux-${ARCH}-${VERSION}.gz" \
    && gunzip /tmp/mihomo.gz \
    && mv /tmp/mihomo /usr/bin/mihomo \
    && chmod +x /usr/bin/mihomo \
    && setcap cap_net_admin,cap_net_raw+ep /usr/bin/mihomo

# Download metacubexd dashboard
RUN mkdir -p /ui \
    && curl -L -o /tmp/ui.zip https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip \
    && unzip /tmp/ui.zip -d /tmp \
    && mv /tmp/metacubexd-gh-pages/* /ui \
    && rm -rf /tmp/ui.zip /tmp/metacubexd-gh-pages

CMD [ "/run.sh" ]
