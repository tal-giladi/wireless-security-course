#!/usr/bin/env bash
# setup-check.sh — verify the lab toolchain and report versions. Read-only; transmits nothing.
# Usage: ./setup-check.sh
set -uo pipefail

echo "== Wireless lab setup check =="
echo "Kernel: $(uname -r)"
echo

tools=(iw ip rfkill airodump-ng aircrack-ng aireplay-ng hcxdumptool hcxpcapngtool \
       hashcat tshark hostapd wpa_supplicant kismet reaver)
missing=0
for t in "${tools[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then
    # Most tools print a version on --version or -V; fall back to "present".
    v=$("$t" --version 2>/dev/null | head -n1)
    [ -z "$v" ] && v=$("$t" -V 2>/dev/null | head -n1)
    [ -z "$v" ] && v="present"
    printf '  [ok]   %-16s %s\n' "$t" "$v"
  else
    printf '  [MISS] %-16s not found\n' "$t"
    missing=$((missing+1))
  fi
done
echo
echo "mac80211_hwsim available (virtual path):"
if modinfo mac80211_hwsim >/dev/null 2>&1; then
  echo "  [ok]   module present — the virtual path needs no wireless hardware"
else
  echo "  [MISS] mac80211_hwsim not found — install the kernel module to use the virtual path"
fi
echo
echo "Wireless interfaces (physical path):"
iw dev 2>/dev/null | awk '/Interface/{print "  "$2}' || echo "  (none / iw not available)"
echo
if [ "$missing" -gt 0 ]; then
  echo "Record the versions you actually have in your lab notebook; $missing tool(s) missing."
  echo "Record versions in TOOLS.md is a reference only — your installed versions are what matter."
fi
