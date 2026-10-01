# Publishing warning — review before making this course public

This course teaches real, working wireless-attack techniques (handshake/PMKID capture and cracking,
deauthentication, rogue APs / evil twins, captive-portal credential capture, 802.1X/EAP credential
relay). It is a legitimate professional security-training topic, but review the following before
publishing:

- **Legality framing is present and prominent.** Every offensive lesson/lab must state: targets only
  hardware you own, isolated setup, authorisation required, and that attacking others' networks is
  illegal. Deauth/rogue-AP/capture pages must also note radio regulatory limits (TX power, DFS).
- **No real targets or credentials.** All labs use the learner's own router/`hostapd` AP/hotspot with
  synthetic credentials and canary flags. Confirm no lesson points at a public/third-party SSID.
- **No weaponisation.** No real malware, no credential exfiltration to real endpoints, no detection
  evasion tuned against real products. Captive-portal labs harvest only synthetic lab creds.
- **Shipped capture files** must be self-generated against lab APs, contain only synthetic
  passphrases, and include no real personal/BSSID data from third parties.
- **Adjacent-wireless module (M15)** is awareness-only by design — confirm it stays that way and does
  not grow deep BLE/RFID/SDR attack labs that broaden the risk surface.

If any of the above is not satisfied in the final content, fix it before publishing.
