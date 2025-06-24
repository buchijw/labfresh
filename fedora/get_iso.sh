#!/bin/bash

# Run with get_iso.sh <release> <spin>. For example, ./get_iso.sh 42 KDE

set -eo pipefail

FED_RELEASE=$1
SPIN=$2

if [ -n "$FED_RELEASE" ] && [ -n "$SPIN" ]; then
    echo "============================================"
    echo "Downloading latest Fedora $FED_RELEASE $SPIN (AMD64) LIVE ISO..."
    echo "============================================"
    iso_url=$(echo "https://dl.fedoraproject.org/pub/alt/live-respins/$(curl -s "https://dl.fedoraproject.org/pub/alt/imagelist-alt" | grep  "/live-respins/F$FED_RELEASE-$SPIN" | awk -F '/live-respins/' '{print $2}')")
    echo $iso_url
    aria2c -o ./F$FED_RELEASE-$SPIN-amd64.iso $iso_url
else
    echo "Please specify a release and spin. For example, ./get_iso.sh 42 KDE"
    exit 1
fi
