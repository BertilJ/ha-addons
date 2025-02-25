# syntax = docker/dockerfile:1.4

# Define base image
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Define version variables
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG TARGETARCH
ARG BUILD_ARCH=${TARGETARCH}

# Install required packages and setup s6-overlay (for service management)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
    tzdata \
    xz-utils && \
    \
    # Determine correct architecture for s6-overlay
    S6_ARCH="${BUILD_ARCH}" && \
    if [ "${BUILD_ARCH}" = "i386" ]; then S6_ARCH="i686"; \
    elif [ "${BUILD_ARCH}" = "amd64" ]; then S6_ARCH="x86_64"; \
    elif [ "${BUILD_ARCH}" = "armv7" ]; then S6_ARCH="arm"; fi && \
    \
    # Download and extract s6-overlay for proper service management
    curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" | tar -C / -Jxpf - && \
    curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" | tar -C / -Jxpf - && \
    curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz" | tar -C / -Jxpf - && \
    curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz" | tar -C / -Jxpf - && \
    \
    # Create necessary directories for s6-overlay
    mkdir -p /etc/fix-attrs.d /etc/services.d

# Copy root filesystem (Home Assistant-specific configuration)
#ADD --link rootfs /

# Set environment variables for Home Assistant
ENV CONFIG_PATH=/data/options.json

# Define Home Assistant add-on metadata
LABEL io.hass.version="2.9.7" io.hass.type="addon" io.hass.arch="aarch64|amd64"

# Install Bashio (for Home Assistant add-on utilities)
ADD --link https://github.com/hassio-addons/bashio/archive/v0.14.3.tar.gz /tmp/bashio.tar.gz
RUN mkdir -p /tmp/bashio && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio && \
    mv /tmp/bashio/lib /usr/lib/bashio && \
    ln -s /usr/lib/bashio/bashio /usr/bin/bashio

# Create required runtime directories
RUN mkdir -p /run/s6/container_environment

# Copy run.sh into the container
COPY run.sh /run.sh

# Ensure run.sh is executable
RUN chmod a+x /run.sh

# Set persistent storage paths 
ENV MODULES_PATH="/app/modules"
ENV DATA_DIR="/app/downloads"

# Define working directory
WORKDIR /app/server

# Clear entrypoint and define startup script
ENTRYPOINT []
CMD [ "/run.sh" ]


