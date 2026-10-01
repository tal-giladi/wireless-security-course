---
id: "12.1"
module: 12
minutes: 18
practice_minutes: 20
prerequisites: ["06.1"]
objectives:
  - Describe which management frames PMF protects and the integrity mechanisms it uses.
  - State PMF's limits — what stays cleartext and which frames and stages it does not cover.
  - Explain why PMF rejecting forged deauthentication is the reason WPA3 labs do not depend on deauth.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 — Protected Management Frames, BIP, IGTK, SA Query procedure"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wi-Fi Alliance — WPA3 specification (PMF requirement)"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "Cisco — Configure 802.11w Management Frame Protection (BIP/IGTK, SA Query)"
    url: https://www.cisco.com/c/en/us/support/docs/wireless-mobility/wireless-lan-wlan/212576-configure-802-11w-management-frame-prote.html
last_verified: "2026-10-01"
---

# 12.1 · PMF and 802.11w — what it protects and its limits

Protected Management Frames (PMF, standardised as 802.11w) close the single most abused gap in classic Wi-Fi — forgeable deauthentication and disassociation frames — by adding integrity and replay protection to a specific subset of management frames, but they do not encrypt the air or hide who is on it. This lesson pins down exactly which frames PMF covers, which integrity keys it uses, and the honest limits that explain why a WPA3 assessment never assumes a deauth will land.

## Why this matters

Half the confusion about "modern Wi-Fi security" comes from over- or under-claiming PMF. Say "PMF encrypts management frames" and you will mis-scope a capture; say "WPA3 stops deauth so the network is safe" and you will miss everything PMF never touched. The precise version is a working tool: it tells you that a forged deauth against a PMF-required network will be ignored (so the Module 6 deauth trick is off the table for WPA3, by design), while the SSID, every device MAC, and the association timing are still cleartext for a passive listener. Getting this boundary right is what lets you design a WPA3 lab that proves something real instead of waiting for a deauth that will never work.

## Learning objectives

- Describe **which management frames** PMF protects and the **integrity mechanisms** (MIC, BIP/IGTK, SA Query) it uses.
- State PMF's **limits** — what stays cleartext, and which frames and association stages it does **not** cover.
- Explain why PMF **rejecting forged deauth** is the reason WPA3 labs in this course do **not** depend on a successful deauth.

## Prerequisites

- [06.1 · The 4-way handshake in depth — PSK, PMK, and PTK](../module-06/lesson-01.md) — you need the PTK and the key hierarchy to see where PMF's unicast and group integrity keys come from.

## Concept

### What PMF actually protects

Classic 802.11 management frames are sent in the clear **and unauthenticated**, which is why a forged deauthentication or disassociation ([01.4](../module-01/lesson-04.md), Module 6) knocks a client off. PMF adds **integrity and replay protection** to a specific set of **robust management frames** — notably **deauthentication**, **disassociation**, and certain **robust action** frames (QoS, Block Ack, radio measurement, BSS transition). It does this two ways:

- **Unicast** robust management frames are protected with the **same PTK** as data frames (CCMP/GCMP over the frame body, with the header as additional authenticated data and a replay counter) — so a unicast deauth that is not protected, or whose MIC does not verify, is dropped.
- **Broadcast/multicast** robust management frames are protected for integrity (not confidentiality) by the **Broadcast/Multicast Integrity Protocol (BIP)** using a separate **Integrity Group Temporal Key (IGTK)** delivered during the handshake, carried in a Management MIC element (MMIE).

The capability is advertised in the RSN Capabilities field as two bits ([`MFPC`/`MFPR`](../module-07/lesson-05.md) — Management Frame Protection Capable / Required). WPA3 **requires** PMF (`MFPR` set); WPA2 may offer it as capable-but-not-required.

### Affected scope — the association-stage nuance

A forged deauth is useless once a session is protected, so an attacker's natural next move is to attack the moment **before** protection exists: force a fresh (re)association. PMF addresses this with the **SA Query procedure** and an **Association Comeback Time**. If an already-associated, PMF-protected client appears to send a new association request, the AP does not simply tear down the session; it issues an SA Query to the existing association, and only if that goes unanswered does it accept the new one. This blunts the "spoof an association to reset the session" class — but it is a defined, bounded mechanism, not a guarantee against every association-stage trick, and it protects frames **inside** an established SA, not the very first open-system authentication/association exchange that bootstraps it.

### What PMF does not do

Keep PMF filed under **authenticity of some management frames**, never **confidentiality of the air**:

- It does **not** encrypt **beacons** or **probe responses** — the SSID and capabilities are still advertised in the clear.
- It does **not** hide addressing — every device MAC, the association timing, and the shape of the conversation remain readable by a passive listener ([05.4](../module-05/lesson-04.md)).
- It protects only **robust** management frames; it does not retroactively protect the initial open-system authentication and association frames that happen before keys exist.
- It is **integrity**, not a new cipher: unicast management frames reuse the data PTK, and group frames get BIP integrity without confidentiality.

### What to verify now

On an owned network, "is PMF really on?" is a capability-and-policy question you can answer from a capture and the config: read the **RSN Capabilities** in the beacon/association for `MFPC`/`MFPR`, confirm the AP is set to **required** (not merely capable) for a WPA3 or hardened WPA2 deployment ([`ieee80211w=2`](../module-07/lesson-05.md)), and confirm a client that cannot do PMF is refused where policy demands it. "Capable but not required" still allows a non-PMF association, which silently reopens the forged-deauth path for any client that did not negotiate protection.

### Blue-team view

For defenders, PMF-required is the baseline that neutralises the cheapest, loudest Wi-Fi denial-of-service and the deauth step that many evil-twin flows relied on ([09.2](../module-09/lesson-02.md)). Measure it the course's way — **vulnerable vs hardened**: on a non-PMF (or capable-only) BSS a forged deauth disconnects the client; on a PMF-required BSS the same frame is ignored and the client stays associated. That observable difference, not a vendor checkbox, is the evidence. It is also exactly why every WPA3 lab in this course is designed so that **no step depends on a successful deauth** — on a PMF-required network the deauth simply does not land.

## Hands-on

### Guided walkthrough — read PMF from a capture and reason about its limits (path R)

Recorded-data exercise: you read capability bits and reason about scope. You transmit nothing.

1. From the module zip ([`labs/module-12/`](../../labs/module-12/)), open the supplied beacon/association capture (captures are **PENDING** — [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md); until then use any WPA2/WPA3 capture that contains a beacon and an association).
2. In the beacon's **RSN** element, read the **RSN Capabilities** and record the PMF bits: is Management Frame Protection **Capable** set, and is it **Required**? Classify the BSS as PMF-required, PMF-capable-only, or no PMF.
3. In the same capture, confirm what is still cleartext: read the **SSID**, the device **MACs**, and the association timing straight from the frames — none of that is hidden by PMF.
4. Locate any **deauthentication** or **disassociation** frame. State whether, on this BSS's PMF policy, a *forged* copy of that frame would be accepted or rejected, and why.
5. Write a two-line finding: "PMF = required/capable/absent (evidence: RSN Capabilities bits); forged deauth = rejected/accepted; still cleartext: SSID + MACs + timing."

> [!NOTE]
> **Lab paths:** R only (read RSN Capabilities and reason about scope from a supplied capture — no hardware; proves you can tell what PMF protects from what it leaves cleartext, **not** that you captured or transmitted anything). This is an analysis lab by design — PMF behaviour is read from the capability bits and the course's vulnerable-vs-hardened logic, not demonstrated by sending frames.
> **Start state:** module zip unpacked; Wireshark installed ([TOOLS.md](../../TOOLS.md)); a capture with a beacon, an association, and a deauth/disassoc present (**PENDING** — [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md)).
> **Duration:** ~20 min.
> **Artifacts:** the PMF classification (required / capable / absent) with the RSN-Capabilities evidence, and the two-line finding on forged-deauth acceptance and what stays cleartext.
> **Success criteria:** you correctly classify the BSS's PMF policy from the capability bits and state the forged-deauth outcome and the cleartext residue — *not* any live capture.
> **Cleanup:** none — nothing transmitted or captured. If you additionally query an **owned** AP for its PMF setting, do so only on your own lab equipment ([00.3](../module-00/lesson-03.md)); since WPA3 mandates PMF, no step here needs a deauth.

## Exercise

A colleague reports: "Our new WPA3 guest network uses PMF, so a passive attacker on the parking lot learns nothing, and nobody can be kicked off." Evaluate both halves of that claim precisely. For each half, say what is true, what is overstated, and exactly what evidence from a capture or the AP config you would cite to settle it.

<details>
<summary>Hint</summary>

Split the claim into **confidentiality** ("learns nothing") and **availability/authenticity** ("nobody can be kicked off"). PMF only touches one of those, and only for a subset of frames. Which bits in the RSN element, and which frames in the capture, decide each half?
</details>

<details>
<summary>Reference answer</summary>

**"Learns nothing" is overstated.** PMF adds integrity to a subset of management frames; it does **not** encrypt beacons or probe responses and does not hide addressing, so a passive listener still reads the **SSID**, every **device MAC**, association timing, and the shape of the traffic ([05.4](../module-05/lesson-04.md)). Evidence: the SSID and MACs read straight from the cleartext beacon and association frames in a capture. The honest statement is "payload is protected and some management frames can't be forged," not "nothing leaks."

**"Nobody can be kicked off" is roughly true but needs the policy qualifier.** PMF protects **deauth/disassoc**, so a *forged* deauth is rejected and the client stays associated — the vulnerable-vs-hardened difference you can demonstrate. But this holds only if the AP is PMF **required** (`MFPR`), not merely **capable**: a capable-only BSS still lets a non-PMF client associate, reopening the forged-deauth path for that client. It also does not cover the initial pre-key authentication/association exchange or every association-stage trick (the SA Query procedure bounds, but does not eliminate, that class). Evidence: the **RSN Capabilities** bits showing `MFPR` set (required), plus a non-PMF client being refused. Settle it by citing the capability bits and the AP's `ieee80211w` setting, not the "WPA3" label alone.
</details>

## References

- [IEEE 802.11-2020](https://standards.ieee.org/ieee/802.11/7028/) — Protected Management Frames, BIP/IGTK, the MMIE, and the SA Query procedure.
- [Wi-Fi Alliance — WPA3 security](https://www.wi-fi.org/discover-wi-fi/security) — the PMF-required requirement in WPA3.
- [Cisco — Configure 802.11w MFP](https://www.cisco.com/c/en/us/support/docs/wireless-mobility/wireless-lan-wlan/212576-configure-802-11w-management-frame-prote.html) — which frames are protected, BIP/IGTK, and SA Query, stated operationally.
- [05.4 · Protected versus cleartext frames](../module-05/lesson-04.md) — what stays cleartext regardless of PMF.
- [07.5 · Configuring and verifying WPA3 securely](../module-07/lesson-05.md) — `ieee80211w` / `MFPR` in practice.

## What you should now be able to do

- Name the management frames PMF protects and the integrity mechanisms (unicast PTK MIC, BIP/IGTK, SA Query) it uses.
- State what PMF leaves cleartext and which frames and association stages it does not cover.
- Explain why a PMF-required network makes forged deauth ineffective, and why that is exactly why WPA3 labs in this course never rely on a deauth.
