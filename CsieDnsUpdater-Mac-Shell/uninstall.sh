#!/bin/bash
#
# uninstall.sh — Unload and remove the launchd agent.

set -euo pipefail

LABEL="io.csie.ddns-updater"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"

if [[ -f "$PLIST_PATH" ]]; then
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    rm "$PLIST_PATH"
    echo "Removed: $PLIST_PATH"
else
    echo "Not installed."
fi
