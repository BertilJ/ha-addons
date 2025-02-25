# syntax = docker/dockerfile:1.4
ARG BUILD_FROM

FROM ${BUILD_FROM}

ARG S6_OVERLAY_VERSION=3.1.5.0
ARG TARGETARCH
ARG BUILD_ARCH=${TARGETARCH}

# Install required packages
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
        tzdata \
        xz-utils \
    && S6_ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "i386" ]; then S6_ARCH="i686"; \
    elif [ "${BUILD_ARCH}" = "amd64" ]; then S6_ARCH="x86_64"; \
    elif [ "${BUILD_ARCH}" = "armv7" ]; then S6_ARCH="arm"; fi \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" \
        | tar -C / -Jxpf - \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz" \
        | tar -C / -Jxpf - \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d

# Copy root filesystem
ADD --link rootfs /

# Set environment variables for module persistence
ENV MODULES_PATH="/data/modules"
ENV DATA_DIR="/data/downloads"
ENV ROOT_PATH="/app/server"

# 🔥 Force module paths by creating symbolic links
RUN mkdir -p /data/modules /data/downloads \
    && ln -sfn /data/modules /app/server/modules \
    && ln -sfn /data/downloads /app/server/downloads

# 🔥 Ensure correct permissions
RUN chmod -R 777 /data/modules /data/downloads

# Persist important directories
VOLUME ["/data/modules", "/data/downloads"]

# Set working directory
WORKDIR /app/server

# Ensure run.sh is executable
RUN chmod a+x /run.sh

ENTRYPOINT []
CMD [ "/run.sh" ]
