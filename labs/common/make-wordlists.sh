#!/usr/bin/env bash
# make-wordlists.sh — build the two teaching wordlists for the cracking labs (Module 6, 11).
#   bounded.txt        contains the lab passphrase -> the crack WILL succeed (known achievable result)
#   strong-absent.txt  does NOT contain the strong passphrase -> the crack will NOT succeed in scope;
#                      the correct outcome is to conclude it won't crack and recommend the control.
# No real-world secrets. Synthetic lab passphrases only.
# Usage: ./make-wordlists.sh
set -euo pipefail
out="./wordlists"
mkdir -p "$out"

# Bounded list: a small list that includes the known lab passphrase near the middle.
{
  printf '%s\n' password123 letmein summer2024 Lab-Guest-1 changeme \
    Wireless99 coffee-shop hunter2 "Lab-WiFi-Passw0rd!" admin1234 \
    qwertyui football iloveyou welcome1 trustno1
} > "$out/bounded.txt"

# Strong-password list: plausible guesses that deliberately EXCLUDE the lab's strong passphrase
# (e.g. a 20-char random passphrase configured on the "hardened" AP). Recovery is not expected.
{
  printf '%s\n' password1 Password1 Summer2025 Company2024 Welcome123 \
    LetMeIn2024 Office-Guest Wifi-Guest1 Spring2024! Autumn2024!
} > "$out/strong-absent.txt"

echo "Wrote:"
printf '  %s (%d entries) — contains the bounded lab passphrase\n' "$out/bounded.txt" "$(wc -l < "$out/bounded.txt")"
printf '  %s (%d entries) — excludes the strong passphrase by design\n' "$out/strong-absent.txt" "$(wc -l < "$out/strong-absent.txt")"
echo
echo "The strong-password AP uses a 20+ char random passphrase that is in NEITHER list — that is the point."
