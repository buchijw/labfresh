#!/bin/bash

# Run with get_iso.sh <release> <verify>. For example, ./get_iso.sh noble true

set -eo pipefail

RELEASE=$1
VERIFY=$2

if [ -n "$RELEASE" ]; then
    if [ "$RELEASE" != "skip" ]; then
        echo "============================================"
        echo "Downloading latest Ubuntu Desktop $RELEASE ISO..."
        echo "============================================"
        curl -fZL -o ./$RELEASE-desktop-amd64.iso "https://cdimage.ubuntu.com/$RELEASE/daily-live/current/$RELEASE-desktop-amd64.iso"

        echo "============================================"
        echo "Downloading checksums..."
        echo "============================================"
        download_url="https://cdimage.ubuntu.com/$RELEASE/daily-live/current"
        curl -fZL "https://cdimage.ubuntu.com/$RELEASE/daily-live/current/SHA256SUMS" -o "./SHA256SUMS"
        curl -fZL "https://cdimage.ubuntu.com/$RELEASE/daily-live/current/SHA256SUMS.gpg" -o "./SHA256SUMS.gpg"
    fi
else
    echo "Please specify a release. For example, ./get_iso.sh noble"
    exit 1
fi

if [ "$VERIFY" = "true" ]; then
    echo "============================================"
    echo "Verifying checksums..."
    echo "============================================"
    gpg --verify "./SHA256SUMS.gpg" "./SHA256SUMS"
    sha256sum --check "./SHA256SUMS"
fi
