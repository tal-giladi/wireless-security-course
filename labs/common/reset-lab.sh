#!/usr/bin/env bash
# reset-lab.sh — return the lab to a clean state after any exercise (virtual or physical).
# Stops services, drops rogue APs, restores interfaces to managed mode, removes synthetic creds.
# Usage: sudo ./reset-lab.sh
set -uo pipefail
if [ "$(id -u)" -ne 0 ]; then echo "Run with sudo." >&2; exit 1; fi

echo "Stopping AP / supplicant / attack services…"
for p in hostapd hostapd-wpe wpa_supplicant freeradius eaphammer bettercap kismet \
         airodump-ng aireplay-ng hcxdumptool reaver; do
  pkill -x "$p" 2>/dev/null && echo "  stopped $p" || true
done

echo "Restoring wireless interfaces to managed mode…"
for i in $(iw dev 2>/dev/null | awk '/Interface/{print $2}'); do
  type=$(iw dev "$i" info 2>/dev/null | awk '/type/{print $2}')
  if [ "$type" != "managed" ]; then
    ip link set "$i" down 2>/dev/null || true
    iw dev "$i" set type managed 2>/dev/null || true
    ip link set "$i" up 2>/dev/null || true
    echo "  $i -> managed"
  fi
done

echo "Removing synthetic lab credentials / temp configs…"
rm -f /tmp/hostapd-lab.conf /tmp/wpa_supplicant-lab.conf /tmp/lab-*.conf 2>/dev/null || true

echo "Cleanup done. (If you changed the regulatory domain, reset it: sudo iw reg set <COUNTRY>.)"
