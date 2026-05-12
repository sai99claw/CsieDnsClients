# csie.io DDNS updater config
#
# Copy this file to ~/.csie-ddns.conf and fill in your values.
# The installer will chmod it to 600 so the token isn't world-readable.

# Required:
CSIE_HOSTNAME="your-hostname"   # the label before .csie.io
CSIE_TOKEN="your-token"

# Optional:
# CSIE_LOG_FILE="$HOME/Library/Logs/csie-ddns.log"
# CSIE_STATE_FILE="$HOME/.csie-ddns.state"
# CSIE_FORCE_UPDATE_SECONDS=3600   # re-send even when IP unchanged, once per hour
