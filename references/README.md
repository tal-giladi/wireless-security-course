# References

Primary sources the course cites. Lessons link to the specific item they rely on. External URLs are
volatile — if one has moved, search the title. We cite standards, original research, and vendor
advisories in preference to blog restatements.

## Standards & specifications

- **IEEE 802.11-2020** — the consolidated Wi-Fi standard (framing, RSN, SAE, PMF). https://standards.ieee.org/ieee/802.11/7028/
- **Wi-Fi Alliance — WPA3 Specification** — SAE, transition mode, PMF requirement, OWE (Enhanced Open). https://www.wi-fi.org/discover-wi-fi/security
- **RFC 3748** — Extensible Authentication Protocol (EAP). https://www.rfc-editor.org/rfc/rfc3748
- **RFC 5216** — EAP-TLS. https://www.rfc-editor.org/rfc/rfc5216
- **RFC 2865** — RADIUS. https://www.rfc-editor.org/rfc/rfc2865
- **RFC 8110** — Opportunistic Wireless Encryption (OWE). https://www.rfc-editor.org/rfc/rfc8110

## Original research

- **Dragonblood** — Vanhoef & Ronen, "Dragonblood: Analyzing the Dragonfly Handshake of WPA3 and EAP-pwd" (2019). https://wpa3.mathyvanhoef.com/
- **KRACK** — Vanhoef & Piessens, "Key Reinstallation Attacks" (CCS 2017). https://www.krackattacks.com/
- **FragAttacks** — Vanhoef, "Fragment and Forge" (USENIX 2021). https://www.fragattacks.com/
- **Kr00k** — ESET, CVE-2019-15126 (2020). https://www.welivesecurity.com/2020/02/26/kr00k-serious-vulnerability-affected-encryption-billion-wifi-devices/

## Tooling & practice

- **OffSec PEN-210 (OSWP)** — syllabus / module list (re-verify before relying on the coverage matrix). https://www.offsec.com/courses/pen-210/
- **hashcat** — mode reference, `-m 22000`. https://hashcat.net/wiki/doku.php?id=example_hashes
- **hcxtools / hcxdumptool** — capture and conversion. https://github.com/ZerBea/hcxtools
- **aircrack-ng** — documentation. https://www.aircrack-ng.org/documentation.html
- **Linux `mac80211_hwsim`** — kernel docs. https://www.kernel.org/doc/html/latest/networking/mac80211_hwsim/
- **OWASP — Wireless Security Testing** (as a methodology reference). https://owasp.org/

> [!NOTE]
> Each lesson's front-matter `sources:` lists the specific items it relies on with a `last_verified`
> date that reflects **only what was actually checked** at build time — never an invented date.
