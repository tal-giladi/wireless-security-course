---
id: "12.2"
module: 12
minutes: 18
practice_minutes: 20
prerequisites: ["06.1"]
objectives:
  - Explain key reinstallation against the 4-way handshake as a nonce/replay-counter reset, not a passphrase crack.
  - Identify what KRACK could and could not do, and that the fix shipped in supplicants and APs.
  - Turn KRACK into a patch-level check on an owned device rather than treating it as a live universal break.
volatility: implementation
sources:
  - title: "Vanhoef & Piessens — Key Reinstallation Attacks (KRACK, CCS 2017)"
    url: https://www.krackattacks.com/
  - title: "IEEE 802.11-2020 — 4-way handshake, PTK installation, EAPOL-Key replay counters"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Red Hat — CVE-2017-13077 (key reinstallation) advisory"
    url: https://access.redhat.com/security/cve/cve-2017-13077
last_verified: "2026-10-01"
---

# 12.2 · KRACK — key reinstallation and what to verify now

KRACK (Key Reinstallation Attacks, Vanhoef & Piessens 2017) was a flaw in the Wi-Fi standard's 4-way handshake that let an attacker force a victim to reinstall an already-in-use key, resetting the nonce and replay counters and thereby undermining the confidentiality and integrity the handshake is supposed to guarantee — without ever learning the passphrase. This lesson explains the mechanism precisely, is honest that it was patched years ago in supplicants and APs, and turns it into the only question that matters today: is this specific device patched?

## Why this matters

KRACK is a textbook case of why "famous Wi-Fi attack" must be read as history plus a patch-level question, not a live universal break. If you repeat the 2017 headline uncritically ("WPA2 is broken") you will misadvise a client whose stack has been patched for years; if you wave it away entirely you will miss a genuinely unpatched embedded device or an abandoned IoT supplicant still running the vulnerable code. The skill this lesson builds — and that the whole module generalises in 12.4 — is to hold the precise mechanism (so you know what it did and did not touch), know that the durable fix shipped in 2017, and translate the attack into a concrete version/patch check on owned equipment.

## Learning objectives

- Explain **key reinstallation** against the 4-way handshake as a **nonce / replay-counter reset**, not a passphrase crack.
- Identify what KRACK **could and could not do**, and that the fix **shipped in supplicants and APs** in 2017.
- Turn KRACK into a **patch-level check** on an owned device rather than treating it as a live universal break.

## Prerequisites

- [06.1 · The 4-way handshake in depth — PSK, PMK, and PTK](../module-06/lesson-01.md) — you need the four EAPOL messages, the PTK, and the nonces to see where a key reinstallation lands.

## Concept

### How it worked

The 4-way handshake ([06.1](../module-06/lesson-01.md)) installs the PTK and starts a per-session **nonce** (packet number) and **replay counter** for the data cipher. KRACK abused the handshake's own retransmission logic: because message 3 can be retransmitted if the AP does not see message 4, a man-in-the-middle positioned between client and AP could **block and later replay** message 3. A standard-compliant client, on receiving the replayed message 3, would **reinstall the same PTK** — and in doing so **reset the transmit nonce and replay counter to their starting values**.

Resetting the nonce is the damage. CCMP's security depends on never reusing a nonce with the same key; forcing a reset causes **nonce reuse**, which lets an attacker replay, decrypt, and in some configurations forge frames. The variants span the 4-way handshake, the group-key handshake, and the Fast BSS Transition (FT) handshake (the CVE series CVE-2017-13077 through CVE-2017-13088). One Android/Linux `wpa_supplicant` variant was especially severe because it reinstalled an **all-zero** key. Crucially, **none of this recovers the passphrase or the PMK** — KRACK is a protocol-state attack against key *installation*, not an offline crack of the kind Module 6 covers.

### Affected scope and versions

Because the flaw was in the standard's handshake behaviour, "any correct WPA2 implementation" was potentially affected — and WPA3's handshake inherits the same retransmission logic, so the class is not WPA2-only in principle. The attack is **active and local**: it requires a man-in-the-middle within radio range during a handshake (typically a same-channel or channel-based MITM), not a passive capture from afar. It targets mainly the **client side** (the supplicant that reinstalls the key), though some AP and FT paths were implicated. Datable targets: pre-October-2017 **wpa_supplicant/hostapd** and unpatched vendor firmware and OS Wi-Fi stacks of that era.

### Mitigation and patch status

The durable fix shipped in **2017**: coordinated patches to `wpa_supplicant`/`hostapd` and to vendor OS and firmware stacks make the supplicant **refuse to reinstall an already-installed key** (and refuse the all-zero key), closing the nonce-reset. Mainstream operating systems (Windows, macOS, Linux, Android, iOS) and major AP vendors released KRACK patches within weeks of the October 2017 disclosure. A current, updated client or AP is **not** exposed to the 2017 attack. That is not a blanket "safe": long-lived **embedded and IoT** devices, abandoned firmware, and stacks that never received the update can still run the vulnerable key-installation logic.

### What to verify now

KRACK today is a **patch-level determination**, not an exploit you re-run. For an owned device, establish: the OS/firmware build and its date, whether that build is at or past the vendor's KRACK fix, and (for the specific CVEs) whether the vendor advisory lists the device as patched. For a supplicant, confirm the `wpa_supplicant`/`hostapd` version is past the October-2017 fix. Record a verdict in the form "build X, dated Y, ≥ vendor KRACK fix → not exposed," or "unpatched/abandoned firmware → exposed to the 2017 key-reinstallation class; recommend update or replacement."

### Blue-team view

For defenders, KRACK's practical lesson outlived the bug: **keep supplicants and AP/firmware patched**, and treat Wi-Fi as a medium where a same-channel MITM is possible, so end-to-end protections (TLS, VPN) must not depend on the link being uncompromised. Note what did **not** fix KRACK — rotating the passphrase does nothing, because the passphrase was never the weakness. The measurable vulnerable-vs-hardened difference is a patched supplicant **refusing** the replayed message 3 (no key reinstallation) versus an unpatched one reinstalling the key and resetting the nonce; on a patched stack the attack simply does not progress.

## Hands-on

### Guided walkthrough — turn KRACK into a patch verdict (path R)

Reading/analysis exercise: you read advisories and version output and produce a check. You do not run the attack.

1. Open the KRACK reference and note three things in your own words: the mechanism (replayed message 3 → key reinstallation → nonce reset), that it is an **active local MITM**, and that it does **not** recover the passphrase.
2. List the handshake variants affected (4-way, group-key, FT) and the especially severe **all-zero-key** `wpa_supplicant` variant, with the representative CVE identifier (CVE-2017-13077 and its siblings).
3. Pick one **owned** device class (e.g. your lab laptop's supplicant, an owned AP, an owned IoT device). Determine where you would read its version/build and how you would compare it against the vendor's KRACK fix date or advisory.
4. Write the **check**: the exact field to read (e.g. `wpa_supplicant -v`, firmware build string, vendor advisory status), the fixed-version threshold, and the pass/fail verdict format.
5. State, in one line, why a found-patched result closes KRACK for that device and why "WPA2 is broken by KRACK" is the wrong way to report it.

> [!NOTE]
> **Lab paths:** R only (read the advisory and version/build output, produce a written patch check — no hardware, no exploitation). KRACK is **not** re-exploited here by design: it needs a reliable active man-in-the-middle during a live handshake, which a recorded or virtual setting does not reproduce, and the lesson's objective is the patch-level judgement, not a working attack.
> **Start state:** the KRACK reference open; access to one owned device's version/build string or its vendor advisory ([TOOLS.md](../../TOOLS.md)).
> **Duration:** ~20 min.
> **Artifacts:** a written KRACK check (field to read + fixed-version threshold + verdict format) and a one-line exposure verdict for one owned device.
> **Success criteria:** you correctly classify the owned device as patched or exposed with evidence (build/version vs the 2017 fix), *not* any demonstration of the attack.
> **Cleanup:** none — nothing transmitted. Reading a version string from an **owned** device is a local query only; this check depends on no deauth and on no frame injection ([00.3](../module-00/lesson-03.md)).

## Exercise

A client sends you two devices and the message: "Prove KRACK is dead on our network." Device A is a laptop whose OS was last updated last month; Device B is a Wi-Fi thermostat whose firmware is dated 2016 and has no available update. Write the position you would report for each device, the specific evidence you would collect, and why rotating the Wi-Fi passphrase is not part of the answer.

<details>
<summary>Hint</summary>

KRACK is a key-installation flaw fixed by patching the supplicant/firmware — it is not a passphrase problem and not something you re-exploit. For each device the question is only "is this build at or past the 2017 fix?" What evidence answers that, and which device can you actually clear?
</details>

<details>
<summary>Reference answer</summary>

**Device A (laptop, updated last month):** report it as **not exposed** to the 2017 KRACK class, because mainstream OS Wi-Fi stacks were patched within weeks of the October-2017 disclosure to refuse reinstalling an already-installed key (and the all-zero key). Evidence: the OS build/version and its update date, shown to be at or past the vendor's KRACK fix; no need to run the attack. The report wording is "patched build, not exposed," not "WPA2 is broken."

**Device B (2016 thermostat, no update):** report it as **potentially exposed** to the key-reinstallation class — it predates the fix and cannot be patched, so its supplicant may still reinstall the key and reset the nonce under an active MITM. Evidence: the firmware build date vs the vendor's (absent) KRACK fix. Recommend compensating controls: isolate it on a segmented IoT SSID/VLAN, and rely on end-to-end protections, since the link may be attackable at close range. **Rotating the passphrase is irrelevant** to both devices: KRACK never recovered the PMK or passphrase — it attacked key installation — so a new passphrase changes nothing about exposure. The correct, honest report is a per-device patch verdict, not a protocol-wide "WPA2 is broken."
</details>

## References

- [KRACK — krackattacks.com](https://www.krackattacks.com/) — Vanhoef & Piessens, 2017: the mechanism, the variants, and the disclosure/patch timeline.
- [IEEE 802.11-2020](https://standards.ieee.org/ieee/802.11/7028/) — the 4-way/group-key handshakes, PTK installation, and EAPOL-Key replay counters KRACK abused.
- [Red Hat — CVE-2017-13077](https://access.redhat.com/security/cve/cve-2017-13077) — a representative vendor advisory for one KRACK CVE and its fixed packages.
- [06.1 · The 4-way handshake in depth](../module-06/lesson-01.md) — the handshake KRACK targeted, and why KRACK is not an offline crack.

## What you should now be able to do

- Explain KRACK as a replayed-message-3 key reinstallation that resets the nonce, not a passphrase recovery.
- State what KRACK required (active local MITM), the variants affected, and that the fix shipped in supplicants and APs in 2017.
- Produce a patch-level check that classifies an owned device as patched or exposed, and report it without the "WPA2 is broken" overstatement.
