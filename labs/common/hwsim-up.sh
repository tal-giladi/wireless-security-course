#!/usr/bin/env bash
# hwsim-up.sh — create N simulated 802.11 radios with mac80211_hwsim (virtual path).
# These radios do NOT transmit over the air. They reproduce protocol flows and config, NOT real RF,
# drivers, range, interference, or injection quirks — see curriculum/lab-matrix.md.
# Usage: sudo ./hwsim-up.sh [N]   (default 2)
set -euo pipefail
N="${1:-2}"

if [ "$(id -u)" -ne 0 ]; then echo "Run with sudo." >&2; exit 1; fi

if lsmod | grep -q '^mac80211_hwsim'; then
  echo "mac80211_hwsim already loaded; reloading with $N radios."
  modprobe -r mac80211_hwsim || true
fi
modprobe mac80211_hwsim radios="$N"

echo "Simulated radios up. Interfaces:"
iw dev | awk '/Interface/{print "  "$2}'
echo
echo "Typical roles: one wlan as AP (hostapd), one as client (wpa_supplicant), one as monitor."
echo "Tear down with: sudo ./hwsim-down.sh"
