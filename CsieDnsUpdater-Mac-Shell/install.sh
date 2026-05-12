#!/bin/bash
#
# install.sh — Register csie-ddns.sh with launchd so it runs every 5 minutes.
#
# Prereq: ~/.csie-ddns.conf exists (copy from config.example.sh and edit).
# Re-run any time to reload the agent after editing the script or config.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/csie-ddns.sh"
TEMPLATE_PATH="$SCRIPT_DIR/io.csie.ddns-updater.plist.template"
LABEL="io.csie.ddns-updater"
LAUNCH_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$LAUNCH_DIR/$LABEL.plist"
LOG_DIR="$HOME/Library/Logs"
CONFIG_FILE="$HOME/.csie-ddns.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Missing config file: $CONFIG_FILE"
    echo "  cp $SCRIPT_DIR/config.example.sh $CONFIG_FILE"
    echo "  \$EDITOR $CONFIG_FILE"
    exit 1
fi

chmod 600 "$CONFIG_FILE"
chmod +x "$SCRIPT_PATH"

mkdir -p "$LAUNCH_DIR" "$LOG_DIR"

sed \
    -e "s|__SCRIPT_PATH__|$SCRIPT_PATH|g" \
    -e "s|__LOG_DIR__|$LOG_DIR|g" \
    "$TEMPLATE_PATH" > "$PLIST_PATH"

launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo "Installed: $PLIST_PATH"
echo "Logs:      $LOG_DIR/csie-ddns.log"
echo
echo "Run once now:"
echo "  bash $SCRIPT_PATH && tail -n 3 $LOG_DIR/csie-ddns.log"
