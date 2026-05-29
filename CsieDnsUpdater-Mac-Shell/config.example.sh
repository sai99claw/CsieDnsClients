# DDNS updater config — supports csie.io or DuckDNS.
#
# Copy this file to ~/.csie-ddns.conf and fill in your values.
# The installer will chmod it to 600 so the token isn't world-readable.

# Required: which provider to use (csie | duckdns).
DDNS_PROVIDER=duckdns

# --- DDNS_PROVIDER=csie ---------------------------------------------------
# CSIE_HOSTNAME="your-hostname"   # the label before .csie.io
# CSIE_TOKEN="your-token"

# --- DDNS_PROVIDER=duckdns ------------------------------------------------
DUCKDNS_DOMAIN="your-subdomain"   # the label before .duckdns.org
DUCKDNS_TOKEN="your-token"

# --- Optional, applies to both providers ---------------------------------
# CSIE_LOG_FILE="$HOME/Library/Logs/csie-ddns.log"
# CSIE_STATE_FILE="$HOME/.csie-ddns.state"
# CSIE_FAIL_STATE_FILE="$HOME/.csie-ddns.fail"
# CSIE_FORCE_UPDATE_SECONDS=3600   # re-send even when IP unchanged, once per hour
# CSIE_BACKOFF_AFTER_FAILS=3       # consecutive failures before backoff kicks in
# CSIE_BACKOFF_SECONDS=21600       # spacing between attempts while in backoff (6h)
