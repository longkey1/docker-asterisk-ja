#!/bin/bash
set -e

# Configure Asterisk language settings from environment variables
ASTERISK_LANGUAGE=${ASTERISK_LANGUAGE:-ja}
ASTERISK_LANGUAGE_PREFIX=${ASTERISK_LANGUAGE_PREFIX:-yes}
ASTERISK_TRANSMIT_SILENCE=${ASTERISK_TRANSMIT_SILENCE:-yes}

# Apply configuration if not already set
if ! grep -q "^defaultlanguage" /etc/asterisk/asterisk.conf; then
    sed -i "/\[options\]/a languageprefix = ${ASTERISK_LANGUAGE_PREFIX}\ndefaultlanguage = ${ASTERISK_LANGUAGE}\ntransmit_silence = ${ASTERISK_TRANSMIT_SILENCE}" /etc/asterisk/asterisk.conf
    echo "Applied language configuration: ${ASTERISK_LANGUAGE}"
fi

# Start Asterisk in foreground mode
exec /usr/sbin/asterisk -f -vvg
