FROM debian:trixie-slim AS base

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libedit2 \
    libjansson4 \
    libsqlite3-0 \
    libssl3 \
    libxml2 \
    msmtp \
    msmtp-mta \
    uuid-runtime \
    && rm -rf /var/lib/apt/lists/*

FROM base AS build

# Asterisk version (passed from build-args, see VERSION file)
ARG ASTERISK_VERSION

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libedit-dev \
    libjansson-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    uuid-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and build Asterisk
WORKDIR /tmp
RUN curl -fsSL https://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz \
    -o asterisk.tar.gz && \
    tar -xzf asterisk.tar.gz && \
    cd asterisk-${ASTERISK_VERSION} && \
    ./configure --with-jansson-bundled && \
    make -j$(nproc) && \
    make install && \
    make samples && \
    cd / && \
    rm -rf /tmp/asterisk-${ASTERISK_VERSION} /tmp/asterisk.tar.gz

# Archive libraries for final stage
RUN tar -czf /tmp/asterisk-libs.tar.gz \
    /usr/lib/libasterisk* \
    /usr/lib/x86_64-linux-gnu/libasterisk* || true

FROM base AS final

# Copy compiled Asterisk from build stage
COPY --from=build /usr/lib/asterisk /usr/lib/asterisk
COPY --from=build /usr/sbin/asterisk /usr/sbin/asterisk
COPY --from=build /usr/sbin/astdb2sqlite3 /usr/sbin/astdb2sqlite3
COPY --from=build /usr/sbin/safe_asterisk /usr/sbin/safe_asterisk
COPY --from=build /var/lib/asterisk /var/lib/asterisk
COPY --from=build /var/spool/asterisk /var/spool/asterisk
COPY --from=build /var/log/asterisk /var/log/asterisk
COPY --from=build /var/run/asterisk /var/run/asterisk
COPY --from=build /etc/asterisk /etc/asterisk
COPY --from=build /tmp/asterisk-libs.tar.gz /tmp/asterisk-libs.tar.gz

# Extract libraries
RUN tar -xzf /tmp/asterisk-libs.tar.gz -C / && rm /tmp/asterisk-libs.tar.gz

# Create asterisk user and group
RUN groupadd -r asterisk && \
    useradd -r -g asterisk -d /var/lib/asterisk -s /bin/false asterisk && \
    chown -R asterisk:asterisk /var/lib/asterisk /var/spool/asterisk /var/log/asterisk /var/run/asterisk /etc/asterisk

# Download and install Japanese sound files
RUN mkdir -p /var/lib/asterisk/sounds/ja && \
    curl -fsSL http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-ja-gsm-current.tar.gz \
    | tar -xz -C /var/lib/asterisk/sounds/ja && \
    chown -R asterisk:asterisk /var/lib/asterisk/sounds/ja && \
    ln -s /var/lib/asterisk/sounds/ja /usr/share/asterisk/sounds/ja

# Note: Configuration is done via environment variables at runtime.
# Default configuration files are included from the Asterisk package.
# Users should extract, customize, and mount their own configuration files at runtime.
# Mount custom configs: -v ./sip.conf:/etc/asterisk/sip.conf:ro

# Expose SIP and RTP ports
EXPOSE 5060/udp 10000-10200/udp

# Add entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Add healthcheck script
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
