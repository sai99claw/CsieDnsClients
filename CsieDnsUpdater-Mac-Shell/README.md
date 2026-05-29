# CsieDnsUpdater (Shell + launchd) for macOS

A zero-dependency, shell-based replacement for the original Swift Mac client.
The original (`CsieDnsUpdater/`) was written for Swift 1.x/2.x in 2015 and no
longer compiles on modern Xcode toolchains. This version does exactly the same
job using only `bash`, `curl`, and `launchd` — all pre-installed on macOS.

Supports two providers:
- **csie.io** — the original target
- **DuckDNS** — fallback for when csie.io is unavailable, so a single
  install + LaunchAgent can be repointed by editing one config line

## What it does

1. Reads provider + credentials from `~/.csie-ddns.conf`.
2. Fetches the host's current public IP (with fallback IP-echo endpoints).
3. Sends the appropriate update request:
   - csie.io: `https://csie.io/update?hn=<host>&token=<token>&ip=<ip>`
   - DuckDNS: `https://www.duckdns.org/update?domains=<host>&token=<token>&ip=<ip>`
4. Caches the last successful IP locally so unchanged IPs aren't re-sent
   every cycle (but forces a re-send hourly as a safety net).
5. Logs every run to `~/Library/Logs/csie-ddns.log`.
6. Recognises the current csie.io response codes (`OK`, `KO2`, `KO4`, `KO5`, `KO6`, `KO7`) and DuckDNS's `OK`/`KO` with distinct log messages.
7. After 3 consecutive server-side failures, falls back to a 6-hour retry interval (configurable) until the next success. Avoids hammering the API when there is a server-side problem.

## Install

```bash
cp config.example.sh ~/.csie-ddns.conf
$EDITOR ~/.csie-ddns.conf        # pick DDNS_PROVIDER and fill in credentials
./install.sh                     # registers a LaunchAgent (runs every 5 min)
```

## Uninstall

```bash
./uninstall.sh
```

## Files

| File | Purpose |
| --- | --- |
| `csie-ddns.sh` | Core updater. Safe to run standalone. |
| `config.example.sh` | Template for `~/.csie-ddns.conf`. |
| `io.csie.ddns-updater.plist.template` | LaunchAgent template (paths are substituted by `install.sh`). |
| `install.sh` | Materialises the plist and `launchctl load`s it. |
| `uninstall.sh` | Unloads and removes the LaunchAgent. |

## Customisation

All settings are environment variables read from `~/.csie-ddns.conf`:

- `DDNS_PROVIDER` (required) — `csie` or `duckdns`
- For `csie`: `CSIE_HOSTNAME`, `CSIE_TOKEN`
- For `duckdns`: `DUCKDNS_DOMAIN`, `DUCKDNS_TOKEN`
- `CSIE_LOG_FILE` — log path (default: `~/Library/Logs/csie-ddns.log`)
- `CSIE_STATE_FILE` — last-known-IP cache (default: `~/.csie-ddns.state`)
- `CSIE_FORCE_UPDATE_SECONDS` — force a re-send even if IP unchanged (default 3600)
- `CSIE_BACKOFF_AFTER_FAILS` — consecutive failures before backoff (default 3)
- `CSIE_BACKOFF_SECONDS` — spacing between attempts while in backoff (default 21600 = 6h)

Change the update interval by editing `StartInterval` in the installed plist
at `~/Library/LaunchAgents/io.csie.ddns-updater.plist`, then re-run
`./install.sh` to reload.
