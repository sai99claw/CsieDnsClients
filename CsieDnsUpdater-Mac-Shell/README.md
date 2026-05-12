# CsieDnsUpdater (Shell + launchd) for macOS

A zero-dependency, shell-based replacement for the original Swift Mac client.
The original (`CsieDnsUpdater/`) was written for Swift 1.x/2.x in 2015 and no
longer compiles on modern Xcode toolchains. This version does exactly the same
job using only `bash`, `curl`, and `launchd` — all pre-installed on macOS.

## What it does

1. Reads `hostname` and `token` from `~/.csie-ddns.conf`.
2. Fetches the host's current public IP (with fallback IP-echo endpoints).
3. Sends the standard csie.io update request:
   `https://csie.io/update?hn=<host>&token=<token>&ip=<ip>`
4. Caches the last successful IP locally so unchanged IPs aren't re-sent
   every cycle (but forces a re-send hourly as a safety net).
5. Logs every run to `~/Library/Logs/csie-ddns.log`.
6. Recognises the current server response codes: `OK`, `KO2`, `KO4`, `KO6`.

## Install

```bash
cp config.example.sh ~/.csie-ddns.conf
$EDITOR ~/.csie-ddns.conf        # fill in CSIE_HOSTNAME and CSIE_TOKEN
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

- `CSIE_HOSTNAME` (required) — the label before `.csie.io`
- `CSIE_TOKEN` (required) — your csie.io update token
- `CSIE_LOG_FILE` — log path (default: `~/Library/Logs/csie-ddns.log`)
- `CSIE_STATE_FILE` — last-known-IP cache (default: `~/.csie-ddns.state`)
- `CSIE_FORCE_UPDATE_SECONDS` — force a re-send even if IP unchanged (default 3600)

Change the update interval by editing `StartInterval` in the installed plist
at `~/Library/LaunchAgents/io.csie.ddns-updater.plist`, then re-run
`./install.sh` to reload.
