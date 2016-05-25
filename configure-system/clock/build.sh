#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

function build() {
    cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL
EOF
}

# Run the installation procedure
time { build; }
# Verify installation
if [ -f "/etc/adjtime" ]; then
    touch DONE
fi