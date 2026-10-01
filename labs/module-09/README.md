# Module 9 labs — Rogue AP, evil twin & client-side

These labs build a controlled rogue AP and test which clients it can draw, always on **synthetic** SSIDs
and **owned, controlled** clients. Every attack here is conditional on client behaviour, and several are
passed by demonstrating a **defence** works (a hardened client that does not auto-join the twin).

> [!WARNING]
> LAB TARGET vs REAL NETWORK — you may advertise **only synthetic SSIDs** of networks you own and attract
> **only controlled clients you own**, on your allowlist, at minimum TX power
> ([00.3](../../lessons/module-00/lesson-03.md)). **Never** clone a real/third-party ESSID, respond to or
> brute-force the PNLs of devices you do not own, imitate a real organisation's captive portal, or target a
> non-consenting person. Impersonation/interference against others is unlawful, not a pentest. Prefer the
> virtual (`mac80211_hwsim`) path for transmit-heavy work.

## Paths and what each proves

| Lab | V (`mac80211_hwsim`) | P (owned AP + client) |
|---|---|---|
| 09.1 rogue-AP mechanics | stands up `hostapd`/`hostapd-mana`, shows association logic; a controlled client is required | real RF, range, TX-power behaviour of a live rogue AP |
| 09.2 evil twin (conditional) | vulnerable vs hardened `wpa_supplicant` clients join/decline; simulates client policy | genuine OS auto-join prompts, MAC-randomisation defaults, signal competition |
| 09.3 captive portal | portal mechanics + synthetic-credential capture from a consented client | real OS captive-portal handoff and browser certificate behaviour |
| 09.4 KARMA/MANA/known-beacon | the PNL-dependent logic; a populated-PNL client is drawn, a clean one is not | real modern probing/randomisation resisting the techniques |
| 09.5 detect & defend | detection logic + the vulnerable-vs-hardened client measurement | real signal-anomaly detection and genuine client behaviour |

Lab 09.5 additionally supports path **R** (a supplied survey/capture of a legitimate AP plus a same-SSID
rogue) to practise detection *reasoning* with no hardware. R and V never grant physical credit.

A **controlled client is required** on every lab in this module — there is no "recorded-only" path for the
attacks, because the whole subject is how a client behaves.

## Tools

`hostapd` and `hostapd-mana` (rogue AP / KARMA / MANA), `dnsmasq` (DHCP/DNS redirect for the portal), a
minimal local web server (portal page + log), optionally `wifiphisher` and `eaphammer` (technique-first,
generic templates only), `airodump-ng` / `kismet` (survey, client profiling, detection), `wpa_supplicant`
(the controlled client). See `../../TOOLS.md`; versions are `VERIFY` at build time and `hostapd-mana`
option names are build-dependent — read the installed example config, not an old blog.

## Known starting state, artifacts, success, cleanup

- **Start:** virtual radios up ([03.3](../../lessons/module-03/lesson-03.md)) or an AP-mode-capable adapter
  verified ([03.4](../../lessons/module-03/lesson-04.md)); one or two owned controlled clients; regulatory
  domain set. Synthetic SSIDs (`Lab-Open-01`, `Lab-PSK-01`, `Lab-Rogue-01`) and synthetic credential
  `Lab-WiFi-Passw0rd!`; a generic, non-branded portal template for 09.3.
- **Artifacts:** `hostapd`/`hostapd-mana` config and logs (including `AP-STA-CONNECTED` lines); a
  two-client vulnerable-vs-hardened table; a portal log holding the submitted **synthetic** credential
  (09.3); a detection note identifying a rogue by BSSID/channel/signal anomaly (09.5).
- **Success:** draw a vulnerable-configured controlled client under a **named** condition **and** show a
  hardened client that does not auto-join the twin — demonstrating the defence works is a full pass.
  Concluding "this client is not vulnerable" (modern-client resistance) is also a full pass.
- **Cleanup:** stop `hostapd`/`hostapd-mana`/`dnsmasq`/the web server; delete any captured synthetic
  credential; forget synthetic SSIDs on your test clients; restore interfaces with
  [`../common/reset-lab.sh`](../common/reset-lab.sh); on the virtual path, `../common/hwsim-down.sh`.

## Shipped captures

The detection exercise in 09.5 uses a survey/capture showing a legitimate AP alongside a same-SSID rogue
on a different BSSID/channel. Like the rest of the course's captures it is **PENDING** a verified
generation run and will carry provenance + licence + SHA-256 when generated — see
[`../common/CAPTURES.md`](../common/CAPTURES.md). No real-network or non-synthetic capture is ever shipped.
