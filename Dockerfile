FROM debian:trixie-slim

# Install Asterisk and required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    asterisk \
    ca-certificates \
    curl \
    msmtp \
    msmtp-mta \
    && rm -rf /var/lib/apt/lists/*

# Create asterisk directories
RUN mkdir -p /var/lib/asterisk/sounds/ja

# Download and extract Japanese sound files
RUN curl -L http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-ja-gsm-current.tar.gz \
    | tar -xz -C /var/lib/asterisk/sounds/ja \
    && chown -R asterisk:asterisk /var/lib/asterisk/sounds/ja \
    && ln -s /var/lib/asterisk/sounds/ja /usr/share/asterisk/sounds/ja

# Note: Configuration is done via environment variables at runtime.
# Default configuration files are included from the Asterisk package.
# Users should extract, customize, and mount their own configuration files at runtime.
# Mount custom configs: -v ./sip.conf:/etc/asterisk/sip.conf:ro

# Expose SIP and RTP ports
EXPOSE 5060/udp 10000-20000/udp

# Add entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Add healthcheck script
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ["/usr/local/bin/healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
