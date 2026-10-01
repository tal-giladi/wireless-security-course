#!/usr/bin/env bash
# hwsim-down.sh — remove the simulated radios created by hwsim-up.sh.
# Usage: sudo ./hwsim-down.sh
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then echo "Run with sudo." >&2; exit 1; fi

# Stop anything that may be holding the interfaces.
pkill -x hostapd 2>/dev/null || true
pkill -x wpa_supplicant 2>/dev/null || true

if lsmod | grep -q '^mac80211_hwsim'; then
  modprobe -r mac80211_hwsim
  echo "mac80211_hwsim unloaded."
else
  echo "mac80211_hwsim was not loaded."
fi
