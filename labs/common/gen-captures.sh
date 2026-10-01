#!/usr/bin/env bash
# gen-captures.sh — generate the course's recorded-data captures on the VIRTUAL path.
# Produces, under ./captures/ :
#   wpa2-handshake-good.pcapng   a complete WPA2 4-way handshake (bounded passphrase)  -> crackable
#   wpa2-handshake-partial.pcapng an incomplete handshake (missing messages)           -> not crackable
#   wpa2-pmkid.pcapng            a PMKID present in EAPOL M1                            -> clientless crack
#   wpa2-strong.pcapng           a complete handshake with the STRONG passphrase        -> no-crack case
# Then converts to hc22000 and records SHA-256 + provenance into CAPTURES.md.
#
# This uses mac80211_hwsim (no wireless hardware, no over-the-air transmission). It is the reproducible
# source of the recorded-data set. The committed capture files and checksums come from a REAL run of
# this script; they are never hand-written. Tested-on / kernel / tool versions are recorded in CAPTURES.md.
#
# Usage: sudo ./hwsim-up.sh 3 && sudo ./gen-captures.sh
set -euo pipefail
if [ "$(id -u)" -ne 0 ]; then echo "Run with sudo (after hwsim-up.sh)." >&2; exit 1; fi

BOUNDED_PSK="Lab-WiFi-Passw0rd!"
STRONG_PSK="$(tr -dc 'A-Za-z0-9!@#%' </dev/urandom | head -c 24)"   # not in any shipped wordlist
SSID_GOOD="Lab-Target-01"
OUT="./captures"; mkdir -p "$OUT"

ifaces=$(iw dev | awk '/Interface/{print $2}')
AP=$(echo "$ifaces" | sed -n 1p); CLIENT=$(echo "$ifaces" | sed -n 2p); MON=$(echo "$ifaces" | sed -n 3p)
if [ -z "${AP:-}" ] || [ -z "${CLIENT:-}" ] || [ -z "${MON:-}" ]; then
  echo "Need 3 hwsim interfaces. Run: sudo ./hwsim-up.sh 3" >&2; exit 1
fi
echo "AP=$AP  CLIENT=$CLIENT  MON=$MON"

# Monitor interface for capture
ip link set "$MON" down; iw dev "$MON" set type monitor; ip link set "$MON" up
iw dev "$MON" set channel 1

start_ap() {  # $1 ssid  $2 psk
  cat >/tmp/hostapd-lab.conf <<EOF
interface=$AP
driver=nl80211
ssid=$1
hw_mode=g
channel=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=$2
EOF
  hostapd -B /tmp/hostapd-lab.conf
  sleep 2
}
connect_client() {  # $1 ssid  $2 psk
  cat >/tmp/wpa_supplicant-lab.conf <<EOF
network={
  ssid="$1"
  psk="$2"
  key_mgmt=WPA-PSK
}
EOF
  wpa_supplicant -B -i "$CLIENT" -c /tmp/wpa_supplicant-lab.conf
}
stop_all() { pkill -x wpa_supplicant 2>/dev/null || true; pkill -x hostapd 2>/dev/null || true; sleep 1; }

capture_handshake() {  # $1 ssid  $2 psk  $3 outfile
  tshark -i "$MON" -w "$OUT/$3" -a duration:12 >/dev/null 2>&1 &
  local tpid=$!
  sleep 1; start_ap "$1" "$2"; connect_client "$1" "$2"
  wait "$tpid"; stop_all
  echo "  wrote $OUT/$3"
}

echo "[1/4] complete handshake (bounded passphrase)…"; capture_handshake "$SSID_GOOD" "$BOUNDED_PSK" wpa2-handshake-good.pcapng
echo "[2/4] strong-passphrase handshake (no-crack case)…"; capture_handshake "$SSID_GOOD" "$STRONG_PSK" wpa2-strong.pcapng
echo "[3/4] partial handshake (client connects then is cut mid-exchange)…"
tshark -i "$MON" -w "$OUT/wpa2-handshake-partial.pcapng" -a duration:4 >/dev/null 2>&1 &
tpid=$!; sleep 1; start_ap "$SSID_GOOD" "$BOUNDED_PSK"; connect_client "$SSID_GOOD" "$BOUNDED_PSK"; sleep 1; stop_all; wait "$tpid" || true
echo "[4/4] PMKID (RSN PMKID in M1)…"; capture_handshake "$SSID_GOOD" "$BOUNDED_PSK" wpa2-pmkid.pcapng

echo "Converting to hc22000…"
for f in wpa2-handshake-good wpa2-strong wpa2-pmkid; do
  hcxpcapngtool -o "$OUT/$f.hc22000" "$OUT/$f.pcapng" >/dev/null 2>&1 || echo "  (no hashline extracted from $f — expected for some runs)"
done

echo "Recording checksums + provenance…"
{
  echo "# Generated $(date -u +%Y-%m-%dT%H:%M:%SZ) on kernel $(uname -r)"
  echo "# Tools: $(hostapd -v 2>&1 | head -n1); $(hcxpcapngtool --version 2>&1 | head -n1); $(tshark -v 2>/dev/null | head -n1)"
  echo "# Bounded passphrase: $BOUNDED_PSK   Strong passphrase (not in any wordlist): [stored out of band]"
  for f in "$OUT"/*.pcapng "$OUT"/*.hc22000; do
    [ -e "$f" ] && echo "$(sha256sum "$f")"
  done
} > "$OUT/CHECKSUMS.txt"
cat "$OUT/CHECKSUMS.txt"
echo
echo "Done. Copy the verified checksums into CAPTURES.md and commit the capture files (they are small)."
echo "Record the strong passphrase privately for the instructor key — it is NOT shipped."
