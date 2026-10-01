# Course outline — Wireless Security & Wi-Fi Penetration Testing

Planning doc, **not imported**. Module/lesson map, dependency graph, lab-path support, template type,
core/elective tag, and the OSWP coverage matrix. Lesson id `NN.M`; the running number in `_sidebar.md`
increments across the course.

All lessons use the **one fixed `##` section set** (instructions §4); the **Tpl** label below is a
planning note for which `###` subsections a lesson uses, not a separate template — see
`curriculum/lesson-templates.md`.

Legend — **Tag:** `core` / `elective`. **Tpl:** F foundation · A attack · D defence/practice.
**Paths:** R recorded-data · V virtual (`mac80211_hwsim`) · P physical. Badges: **F**oundational /
**C**urrent / **E**merging / **D**eprecated(link-only).

Time/cost per path is published to learners in Module 0 and refined as lessons land. Current estimate:
**core path ~45–60 h study + ~30–45 h practice**; electives add ~15–20 h.

---

## Stage 0 — Onboarding  (core)
### Module 0 — How this course works & safe lab practice  (Tpl D)
- 0.1 · What you'll learn, the three lab paths, and expectations · R · **C**
- 0.2 · Readiness self-check & optional preparation path · R · **F**
- 0.3 · Safety, containment & the law (radio ≠ subnet isolation; allowlists; stop conditions) · R · **C**
Depends on: none. Covers review points 2, 4, 12.

## Stage 1 — Foundations & setup  (core)
### Module 1 — RF & 802.11 fundamentals  (Tpl F)
- 1.1 · Radio basics for hackers — spectrum, dB/dBm, antennas · R · **F**
- 1.2 · Bands & channels — 2.4/5/6 GHz, width, DFS, regulatory domains · R · **C**
- 1.3 · The 802.11 frame — management/control/data, addressing, radiotap · R · **F**
- 1.4 · Joining a network — beacons, probes, auth, association, BSS/ESS · R/V · **F**
Depends on: M0. Sim: 802.11 join animation.

### Module 2 — Wi-Fi security protocols & the secure baseline  (Tpl F+D)
- 2.1 · The protocol family — Open, OWE, WPA2, WPA3, Enterprise, PMF · R · **C**
- 2.2 · Key hierarchies at a glance — PSK→PMK→PTK, SAE, 802.1X · R · **C**
- 2.3 · **The secure wireless baseline** (revisited all course) — segmentation, admin, firmware, WPS, client policy, monitoring · R · **C**
- 2.4 · Legacy & deprecated: WEP, TKIP, RC4 — what they were, why dead (link-only) · R · **D**
Depends on: M1. Introduces defence early (review point 8).

### Module 3 — Building your lab (three paths)  (Tpl D)
- 3.1 · Choosing your path — recorded / virtual / physical, and what each proves · R · **C**
- 3.2 · Recorded-data setup — tools, supplied captures, checksums · R · **C**
- 3.3 · Virtual labs with `mac80211_hwsim` — simulated radios, hostapd/wpa_supplicant · V · **C**
- 3.4 · Physical rig — adapter→driver→**monitor**/**injection**/**AP-mode**, `iw`, reg domain · P · **C**
- 3.5 · Windows-hosted VM & USB passthrough — setup + troubleshooting · P · **C**
Depends on: M0. Uses `lab-matrix.md`. Covers review points 4, 5.

## Stage 2 — Recon & analysis  (core)
### Module 4 — Wireless reconnaissance  (Tpl A-lite)
- 4.1 · Passive vs active discovery · R/V/P · **F**
- 4.2 · `airodump-ng` & Kismet — the AP/client view, hidden SSIDs · R/V/P · **C**
- 4.3 · Clients, probe requests & the PNL · R/V/P · **C**
- 4.4 · Wardriving, WiGLE & recon ethics · R · **C**
Depends on: M3.

### Module 5 — Capturing & analysing 802.11  (Tpl F)
- 5.1 · Radiotap & capture formats (pcap/pcapng/hc22000) · R · **C**
- 5.2 · Wireshark for 802.11 — dissection & filters · R · **C**
- 5.3 · Following a join & spotting the handshake · R · **C**
- 5.4 · Protected vs cleartext frames — what you can and can't read · R · **C**
Depends on: M4. Pure analysis — full recorded path.

## Stage 3 — WPA2-Personal  (core)
### Module 6 — WPA2-Personal: capture, PMKID & cracking  (Tpl A+D)
- 6.1 · The 4-way handshake in depth (PSK→PMK→PTK) · R · **C**
- 6.2 · Capturing a handshake — deauth caveats, clean vs partial (success+failure examples) · R/V/P · **C**
- 6.3 · PMKID clientless capture — **when it's available**, not fully passive, detection · R/V/P · **C**
- 6.4 · Offline cracking — hashcat `-m 22000`, **bounded** result + **strong-password** (no-crack) case · R · **C**
- 6.5 · **Hardening WPA2-Personal & measuring** — passphrase entropy, PMF; vulnerable vs hardened · R/V/P · **C**
Depends on: M5. Covers review points 6, 8, 10.

## Stage 4 — WPA3 & WPS
### Module 7 — WPA3-SAE  (core, Tpl A+D)
- 7.1 · SAE (Dragonfly) — why there's no offline-crackable hash · R/V · **C**
- 7.2 · SAE-only vs **transition mode** — the real downgrade surface · V/P · **C**
- 7.3 · Dragonblood — timing/cache side-channels, affected versions, **mitigations** · R · **E**
- 7.4 · OWE (Enhanced Open) — **encryption without authenticating the network** · V/P · **C**
- 7.5 · Configuring & verifying WPA3 securely (SAE-only, PMF required) · V/P · **C**
Depends on: M6. Covers review point 6.

### Module 8 — WPS  (elective, Tpl A)
- 8.1 · How WPS works · R · **F**
- 8.2 · Pixie Dust offline attack — prerequisites & why it may fail · V/P · **C**
- 8.3 · Online PIN brute — mostly-mitigated legacy (summary) · — · **D**
- 8.4 · Prevalence & remediation (disable/limit WPS) · R · **C**
Depends on: M6.

## Stage 5 — Rogue infrastructure & client-side  (core)
### Module 9 — Rogue AP, evil twin & client-side  (Tpl A+D)
- 9.1 · Rogue-AP mechanics & lures · V/P · **C**
- 9.2 · Evil twin — **conditional on client behaviour**; PMF/MAC-randomisation reality · V/P · **C**
- 9.3 · Captive portals — **social engineering, not a crypto break** (lab client, synthetic creds) · V/P · **C**
- 9.4 · KARMA / MANA / known-beacon — PNL-dependent, what modern clients resist · V/P · **E**
- 9.5 · Detecting & defending against rogue APs (blue team) · R/V/P · **C**
Depends on: M6. Covers review points 6, 8.

## Stage 6 — Enterprise (expanded sequence)  (core)
### Module 10 — Enterprise I: architecture, EAP & building the lab  (Tpl F+D)
- 10.1 · 802.1X — supplicant / authenticator / RADIUS; where trust lives · R · **C**
- 10.2 · EAP methods — PEAP, EAP-TTLS, EAP-TLS · R · **C**
- 10.3 · Build the lab — local **CA + FreeRADIUS + supplicant**, server cert, client profile · V · **C**
Depends on: M9, M6.

### Module 11 — Enterprise II: attack, harden & retest  (Tpl A+D)
- 11.1 · Assess insecure config — credential **capture** (`hostapd-wpe`/`eaphammer`) · V/P · **C**
- 11.2 · Cracking captured MSCHAPv2 (bounded) · R · **C**
- 11.3 · **Relay vs capture** — distinguished clearly · V · **C**
- 11.4 · Harden — trusted CA, server identity, managed profiles, cert lifecycle, **EAP-TLS** · V/P · **C**
- 11.5 · **A correctly-configured client rejects the rogue server** — evidence & why · V/P · **C**
Depends on: M10. Covers review points 7, 8.

## Stage 7 — Protections & residual attacks  (elective/advanced)
### Module 12 — Modern protections & famous attacks as context  (Tpl A)
- 12.1 · PMF / 802.11w — what it protects, limits · R · **C**
- 12.2 · KRACK — key reinstallation; what to verify now · R · **C**
- 12.3 · FragAttacks & Kr00k — fragment/clear-key classes · R · **E**
- 12.4 · Reading a wireless CVE → turning it into a check · R · **C**
Depends on: M6, M7.

## Stage 8 — Professional practice  (core)
### Module 13 — Wireless engagements & methodology  (Tpl D)
- 13.1 · Scoping & authorisation for wireless · R · **C**
- 13.2 · Methodology & evidence capture · R · **C**
- 13.3 · Impact assessment & limitations · R · **C**
Depends on: all prior core.

### Module 14 — Defence program & reporting  (Tpl D)
- 14.1 · The defence program — segmentation, monitoring, firmware, client policy (ties the baseline together) · R · **C**
- 14.2 · Writing the wireless pentest report (exec summary + technical evidence) · R · **C**
- 14.3 · Remediation roadmap, residual risk & client communication · R · **C**
Depends on: M13.

## Elective — awareness
### Module 15 — Adjacent wireless (awareness only)  (elective, Tpl F)
- 15.1 · BLE/Bluetooth — scope & where to go deeper · R · **F**
- 15.2 · Zigbee/Thread, RFID/NFC — one paragraph each · R · **F**
- 15.3 · SDR — what it unlocks, legal/scope limits · R · **F**
Depends on: M1. No deep labs by design.

## Capstones (projects/)
- **Recorded-data capstone** — recon, interpret supplied captures, justify techniques, assess, write
  report w/ remediation & residual risk. Path R. Rubric in `assessment-rubrics.md`.
- **Physical-lab capstone** — against the learner's **own** APs: WPA2 via handshake + PMKID, WPA3
  assessment, evil-twin vs a lab client, then harden and **retest**. Path P (V where P unavailable).

---

## OSWP / PEN-210 objective coverage matrix (verified against current 16-module list)

| PEN-210 module/objective | Covered in | Modern change / gap |
|---|---|---|
| IEEE 802.11; Wireless Networks; Frames & interactions | M1 | — |
| Wi-Fi Encryption | M2 | **WEP link-only (gap: exam may expect WEP)** |
| Linux wireless tools/drivers/stacks; Determining chipsets & drivers | M3 | adds virtual `hwsim` path |
| Wireshark Essentials | M5 | — |
| Kismet Essentials | M4 | — |
| Aircrack-ng Essentials; Cracking Authentication Hashes | M6 | crack via hashcat hc22000 (aircrack also shown) |
| Attacking WPS | M8 (elective) | Pixie Dust kept; online brute summary-only |
| Rogue Access Points | M9 | conditional-on-client framing added |
| Attacking Captive Portals | M9.3 | framed as social-eng, not crypto break |
| Attacking WPA Enterprise | M10–M11 | expanded to build→attack→harden→retest |
| bettercap Essentials | M4/M9 (technique) | **gap: deep bettercap tool drills optional** |
| Manual Network Connections | M3.4/M6 | — |
| (not in OSWP) WPA3-SAE / PMKID / PMF / KRACK family | M7, M6.3, M12 | **our additions** |

### Explicit certification-prep gaps (disclosed to learners)
- **WEP** hands-on: not taught as a lab (deprecation rule). Practise separately for OSWP.
- **bettercap** tool-specific fluency: technique covered, deep drills optional.
- This course does **not** promise OSWP pass; it covers most objectives + modern material, with these gaps.

## Dependency graph (summary)
M0 → M1 → M2 → M3 → M4 → M5 → M6 → {M7, M8} ; M6 → M9 → M10 → M11 ; {M6,M7} → M12 ;
(all core) → M13 → M14 ; M1 → M15 ; (all) → capstones.
