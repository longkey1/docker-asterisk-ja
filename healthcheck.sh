#!/bin/bash

# Check if Asterisk is running
if ! pgrep -x "asterisk" > /dev/null; then
    echo "Asterisk is not running"
    exit 1
fi

# Check if Asterisk CLI is responsive
if ! /usr/sbin/asterisk -rx "core show version" > /dev/null 2>&1; then
    echo "Asterisk CLI is not responsive"
    exit 1
fi

echo "Asterisk is healthy"
exit 0
