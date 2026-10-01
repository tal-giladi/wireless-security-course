# Lab compatibility matrix (planning — not imported)

Specify the environment **before** recommending any purchase (plan §5, review point 5). Capability
columns are **separate on purpose**: monitor mode, frame injection, and AP mode are distinct and a
device may support one but not another. **Verify exact model + hardware revision** — a chipset or
marketing name does not guarantee support. Entries below are a **template to be verified at build
time**; anything unverified is marked `VERIFY`. Never invent verification dates.

## Three lab paths at a glance

| Path | Hardware | Proves | Does NOT prove |
|---|---|---|---|
| **R** Recorded-data | none | frame/handshake/EAP interpretation, cracking workflow, reasoning | live capture, injection, RF |
| **V** Virtual (`mac80211_hwsim`) | none (VM) | protocol flows, hostapd/supplicant/RADIUS config, many attack mechanics | real RF, real drivers, range, interference, reg behaviour, HW monitor/injection quirks |
| **P** Physical | adapters + AP + client | real monitor/injection/capture, range, interference | — |

## Wi-Fi adapters (VERIFY each model+revision at build time)

| Model (revision) | Chipset | Driver / status | Bands | Monitor | Injection | AP mode | Notes |
|---|---|---|---|---|---|---|---|
| Alfa AWUS036NHA | AR9271 | `ath9k_htc` (in-kernel) | 2.4 | VERIFY | VERIFY | VERIFY | long-stable 2.4-only; no 5/6 GHz |
| Alfa AWUS036ACM | MT7612U | `mt76` (in-kernel) | 2.4/5 | VERIFY | VERIFY | VERIFY | good dual-band mainline support |
| Alfa AWUS036ACH / AXML etc. | RTL88XXAU | out-of-tree DKMS | 2.4/5 | VERIFY | VERIFY | VERIFY | DKMS fragile across kernels — pin kernel |
| (6 GHz candidate) | VERIFY | VERIFY | 6 | VERIFY | VERIFY | VERIFY | 6 GHz monitor/inject support is thin — VERIFY |

### Buying in Israel (importing adapters is hard — buy by **chipset**, not brand/model)

Mainstream IL retailers (KSP/Ivory/Bug/Lastprice) mostly stock consumer USB adapters that **cannot do
monitor/injection**, and specific SKUs rotate constantly — so the **fallback rule is the real
recommendation: buy any adapter whose chipset is on the known-good list below, and verify the hardware
revision before paying.** Known-good chipsets: **AR9271** (2.4 GHz only), **MT7612U** (dual-band),
**MT7921U** (newer dual-band, Wi-Fi 6), **RTL8812AU** (dual-band, out-of-tree DKMS driver).

Links to try (availability = VERIFY at build time; expect churn):
- **AliExpress — ships to Israel, Hebrew site, sometimes IL-local warehouses** (primary route):
  - Alfa AWUS036ACM / MT7612U search: https://www.aliexpress.com/w/wholesale-awus036acm.html
  - Genuine AR9271 adapter search: https://www.aliexpress.com/w/wholesale-ar9271.html
- **Amazon (ships to Israel):**
  - Alfa AWUS036NHA (AR9271): https://www.amazon.com/s?k=alfa+awus036nha
  - Alfa AWUS036ACM (MT7612U): https://www.amazon.com/s?k=alfa+awus036acm
- **Local IL retailers (search their catalogue; most results won't be monitor-capable — check chipset):**
  - KSP USB WiFi: https://ksp.co.il/?select=.2171 · Ivory: https://www.ivory.co.il/catalog.php?act=cat&id=2308
  - Bug: https://www.bug.co.il · Lastprice: https://www.lastprice.co.il

> [!CAUTION]
> **The TP-Link TL-WN722N trap:** only **v1** is AR9271 (monitor-capable). **v2/v3 are Realtek
> RTL8188EUS and do NOT support monitor mode.** Same with many "AC600/AC1300" cheap sticks. Always
> confirm the exact chipset + hardware revision before buying.

> Decision for Tal: pick which chipset to feature as the course default (recommend **MT7612U**,
> dual-band + mainline `mt76` driver). I'll verify a specific in-stock model+revision before the course
> tells anyone to buy it. The course teaches the chipset-first buying rule so any listed fallback works.

## Target APs / devices — which exercise needs what

| Exercise | Needs | Can use hostapd? | Phone hotspot? |
|---|---|---|---|
| WPA2-Personal handshake/PMKID | any WPA2 AP you own | yes | sometimes (no PMKID guarantee) |
| WPS (Pixie Dust) | AP with WPS enabled | partial | **no** |
| WPA3-SAE / transition / OWE | WPA3-capable AP (or hostapd ≥ supported) | yes (recent hostapd) | **not all WPA3 exercises** |
| WPA-Enterprise / 802.1X | FreeRADIUS + CA + supplicant | yes (core of the lab) | **no** |
| Evil twin / client-side | a controlled test client | yes | n/a |

> **An ordinary phone hotspot does NOT provide Enterprise, WPS, or every WPA3 exercise.** State on labs.

## Test clients
- A **controlled client** we can configure (real device and/or VM `wpa_supplicant`).
- An **enterprise client correctly configured to validate the server cert** (for M11.5 — rejects rogue).
- Note MAC-randomisation / auto-join behaviour per OS — it changes client-side attack outcomes.

## Host OS / kernel / software
- **Windows 11 host → Linux VM** is the primary documented path (Tal's environment).
  - USB passthrough: document VirtualBox (Ext Pack), VMware Workstation, Hyper-V caveats; common
    failures (adapter not claimed, resets on mode change, USB2 vs USB3). `mac80211_hwsim` needs **no**
    passthrough — recommend V path when passthrough fights the learner.
- Linux distro + kernel range: VERIFY (Kali / recent Ubuntu LTS); pin a known-good kernel for DKMS adapters.
- **Pinned software** (also in root `TOOLS.md`, with fallbacks): `aircrack-ng`, `hcxtools`,
  `hcxdumptool`, `hashcat`, `hostapd`, `hostapd-mana`, `hostapd-wpe`, `wpa_supplicant`, `freeradius`,
  `eaphammer`, `bettercap`, `kismet`, `iw`, `wireshark`/`tshark`. Version = VERIFY at build.

## Marking rule
Every cell is `supported (verified <what/how>)`, `VERIFY`, or `unsupported`. Untested hardware
combinations and unsupported commands are called out in the lesson/lab too (review point 13).
