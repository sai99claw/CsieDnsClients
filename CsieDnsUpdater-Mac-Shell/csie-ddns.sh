#!/bin/bash
#
# csie-ddns.sh — Update a csie.io DDNS record with the host's current public IP.
#
# Usage:
#   csie-ddns.sh
#
# Reads config from $CSIE_DDNS_CONFIG (default: ~/.csie-ddns.conf).
# The config file is a shell snippet that must set:
#   CSIE_HOSTNAME  — the label before .csie.io (e.g. "foo" for foo.csie.io)
#   CSIE_TOKEN     — your csie.io update token
# Optionally:
#   CSIE_LOG_FILE  — log path (default: ~/Library/Logs/csie-ddns.log)
#   CSIE_STATE_FILE — last-known-IP cache (default: ~/.csie-ddns.state)
#   CSIE_FORCE_UPDATE_SECONDS — force update even if IP unchanged (default 3600)

set -euo pipefail

CONFIG_FILE="${CSIE_DDNS_CONFIG:-$HOME/.csie-ddns.conf}"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "csie-ddns: config not found at $CONFIG_FILE" >&2
    echo "Copy config.example.sh to $CONFIG_FILE and edit it." >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

if [[ -z "${CSIE_HOSTNAME:-}" || -z "${CSIE_TOKEN:-}" ]]; then
    echo "csie-ddns: CSIE_HOSTNAME and CSIE_TOKEN must be set in $CONFIG_FILE" >&2
    exit 1
fi

LOG_FILE="${CSIE_LOG_FILE:-$HOME/Library/Logs/csie-ddns.log}"
STATE_FILE="${CSIE_STATE_FILE:-$HOME/.csie-ddns.state}"
FORCE_UPDATE_SECONDS="${CSIE_FORCE_UPDATE_SECONDS:-3600}"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

fetch_ip() {
    # Try a couple of IP echo services for resilience.
    for endpoint in \
        https://checkip.amazonaws.com \
        https://ifconfig.me/ip \
        https://api.ipify.org
    do
        if ip=$(curl -fsS --max-time 10 "$endpoint" 2>/dev/null | tr -d '[:space:]'); then
            if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                printf '%s' "$ip"
                return 0
            fi
        fi
    done
    return 1
}

if ! current_ip=$(fetch_ip); then
    log "ERROR: could not determine public IP"
    exit 1
fi

last_ip=""
state_age=$FORCE_UPDATE_SECONDS
if [[ -f "$STATE_FILE" ]]; then
    last_ip=$(<"$STATE_FILE")
    state_mtime=$(stat -f %m "$STATE_FILE" 2>/dev/null || echo 0)
    state_age=$(( $(date +%s) - state_mtime ))
fi

if [[ "$current_ip" == "$last_ip" && $state_age -lt $FORCE_UPDATE_SECONDS ]]; then
    log "no change (ip=$current_ip age=${state_age}s)"
    exit 0
fi

log "updating: last=${last_ip:-<none>} current=$current_ip (age=${state_age}s)"

response=$(curl -fsS --max-time 15 -G \
    --data-urlencode "hn=${CSIE_HOSTNAME}" \
    --data-urlencode "token=${CSIE_TOKEN}" \
    --data-urlencode "ip=${current_ip}" \
    "https://csie.io/update" 2>&1) || {
    log "ERROR: csie.io request failed: $response"
    exit 1
}

case "$response" in
    OK)
        printf '%s' "$current_ip" > "$STATE_FILE"
        log "OK: ${CSIE_HOSTNAME}.csie.io -> $current_ip"
        ;;
    KO|KO2)
        log "FAILED ($response): hostname or token is empty"
        exit 2
        ;;
    KO4)
        log "FAILED ($response): token format invalid"
        exit 2
        ;;
    KO6)
        log "FAILED ($response): token does not authorize this hostname"
        exit 2
        ;;
    KO*)
        log "FAILED ($response): server rejected the request"
        exit 2
        ;;
    *)
        log "FAILED: unexpected response from csie.io: '$response'"
        exit 3
        ;;
esac
