---
id: "09.5"
module: 9
minutes: 18
practice_minutes: 35
prerequisites: ["09.1"]
objectives:
  - Detect a rogue AP by BSSID/SSID and signal anomalies and by client-side policy, and state each method's limits.
  - Apply the client controls — disable auto-join, prune the PNL, validate network identity, keep MAC randomisation on.
  - Measure the vulnerable-versus-hardened difference, showing the hardened client does not auto-join the twin.
volatility: implementation
sources:
  - title: "NIST SP 800-153 — Guidelines for Securing Wireless Local Area Networks (WLANs)"
    url: https://csrc.nist.gov/pubs/sp/800/153/final
  - title: "Kismet documentation — passive detection and alerts"
    url: https://www.kismetwireless.net/docs/readme/intro/kismet/
  - title: "SpecterOps — Modern Wireless Tradecraft Pt II (why hardened clients resist rogue APs)"
    url: https://specterops.io/blog/2019/11/04/modern-wireless-tradecraft-pt-ii-mana-and-known-beacon-attacks/
last_verified: "2026-10-01"
---

# 09.5 · Detecting and defending against rogue APs

Because you cannot stop anyone from broadcasting a rogue AP, defence is about **detecting** one and making your **clients refuse to join** it — and the decisive measurement is a hardened client that does not auto-join the twin that a vulnerable client joined. This blue-team lesson covers rogue detection by BSSID/SSID and signal anomalies and by client policy, the client controls that move a device from vulnerable to hardened, and the vulnerable-versus-hardened comparison you can pass by demonstrating the defence works.

## Why this matters

The rogue-AP attacks in this module all share one defining property: the vulnerability lives in the client's willingness to trust a name, not in any cipher. That is good news for defence, because it means the controls are configuration and monitoring, not cryptography — things a blue team can deploy today. But it also means the *measurement* of success is unusual: you do not "prove the network is secure," you prove that a **specific hardened client declines to associate** with a rogue that a vulnerable client accepts. This lesson gives you both halves — detection (so you know a rogue is present) and client hardening (so it does not matter) — and teaches you to evidence the difference, which is exactly what the course's rubric lets you pass on.

## Learning objectives

- **Detect** a rogue AP by **BSSID/SSID and signal anomalies** and by **client-side policy**, and state each method's limits.
- Apply the **client controls**: disable **auto-join**, prune the **PNL**, **validate network identity**, keep **MAC randomisation** on.
- **Measure** the vulnerable-versus-hardened difference — the hardened client does **not** auto-join the twin.

## Prerequisites

- [09.1 · Rogue-AP mechanics and lures](lesson-01.md) — you need to be able to stand up the rogue AP you will then detect and defend against.

## Concept

### The control or process

Rogue-AP defence has two layers, and a mature program runs both.

**Detection (know a rogue is present).**

- **Wireless IDS / monitoring.** A passive sensor (Kismet, or a managed WLAN's built-in WIDS) continuously inventories every BSSID/SSID it hears and alerts on anomalies: a known SSID appearing on an **unexpected BSSID** or **channel**, a sudden **signal-strength** change for a BSSID (someone closer than the real AP), or a BSSID not on the authorised list. Limit: detection sees what its sensors hear — coverage gaps, a rogue on a band/channel you don't monitor, or a brief appearance can be missed; it tells you a rogue *was present*, not that none ever is.
- **BSSID/signal anomaly checks.** Even without a full WIDS, comparing observed BSSIDs/channels/signal for your SSIDs against a known-good baseline surfaces the obvious evil twin. Limit: an attacker who clones the real BSSID and matches signal is harder to separate; detection is a strong signal, not a guarantee.
- **Client-reported anomalies.** Managed clients can report the networks and BSSIDs they see, feeding central detection. Limit: depends on client enrolment.

**Prevention (make the client refuse to join).** This is the control that actually removes the impact, because the vulnerability is client-side (see below).

### Vulnerable vs hardened — and how to measure

The measurement is the lesson 09.2 twin presented to two clients, with the client controls as the only difference:

- **Vulnerable client:** an open SSID saved with **auto-join on**, stale PNL entries, older OS, randomisation off. Against the twin it logs `AP-STA-CONNECTED` with no user action — it joined the rogue.
- **Hardened client:** **auto-join disabled** for open/sensitive networks, **PNL pruned** of stale open entries, **network-identity validation** preferred (WPA3-SAE / enterprise with server-cert validation, so a familiar name alone is insufficient), **MAC randomisation on**, **OS current** (reduced probing). Against the same twin it does **not** auto-join — no `AP-STA-CONNECTED`, or it prompts/declines — and you capture that as the evidence.

The controls map directly onto the attacks: disabling auto-join and pruning the PNL defeats the silent evil twin (09.2) and the known-beacon attack (09.4); current-OS reduced probing plus MAC randomisation frustrates KARMA/MANA profiling (09.4); network-identity validation means a cloned SSID is not enough (09.2) and underpins the enterprise rejecting-client work in Module 11; user awareness defeats the captive portal (09.3), which no client setting alone can stop because it targets the person. The measurable, reportable result is binary and client-specific: **vulnerable client joins the twin; hardened client does not** — demonstrating the defence works is a valid pass, exactly as the rubric allows.

## Hands-on

### Guided walkthrough — detect, harden, and measure (paths R / V / P)

1. **R (recorded):** open the supplied survey/capture showing a legitimate SSID plus a same-SSID rogue on a different BSSID/channel. Identify the rogue from the BSSID/channel/signal anomaly and write why it is suspicious. (Proves detection *reasoning*, not live sensing.)
2. **V (`mac80211_hwsim`):** stand up the 09.1 twin and run a passive detector/`iw`/`airodump-ng` as your "WIDS"; confirm you can spot the duplicate SSID on the rogue BSSID. Then present the twin to a **vulnerable** `wpa_supplicant` client (open + auto-join) and a **hardened** one (auto-join off, PNL pruned, network-identity preferred); record that the first auto-joins and the second does not.
3. **P (owned gear):** repeat with a real sensor and two owned clients (ideally different OS versions), adding the RF note (signal anomaly is real here). Capture the `hostapd`/client evidence for both.
4. Write the two-row measurement (client, controls, outcome) plus the detection note, and state the defence-works conclusion.

### Lab

> [!NOTE]
> **Lab paths:**
> R (supplied survey/capture of a legitimate AP + a same-SSID rogue — proves you can *recognise* a rogue from BSSID/channel/signal anomalies and reason about detection; does **not** prove live sensing or client behaviour).
> V (`mac80211_hwsim` + the 09.1 twin + a passive detector + two `wpa_supplicant` clients — proves the detection logic and the vulnerable-vs-hardened client measurement; a controlled client is **required**; does **not** reproduce real RF/signal anomalies or real OS auto-join UX).
> P (owned AP-mode adapter + a real sensor + two owned clients — the only path that shows real signal-anomaly detection and genuine OS auto-join/randomisation behaviour).
> **Start state:** R — recorded survey/capture from the module zip. V — hwsim radios up ([03.3](../module-03/lesson-03.md)); 09.1 twin working; a passive detector/`airodump-ng`/Kismet. P — AP-mode adapter + sensor + two owned clients; reg domain set. Synthetic SSIDs only.
> **Duration:** ~15 min (R) / ~30 min (V) / ~35 min (P).
> **Artifacts:** a detection note identifying the rogue by BSSID/channel/signal anomaly; a two-client table (client, controls applied, outcome) with `hostapd` logs showing `AP-STA-CONNECTED` for the vulnerable client and its **absence** for the hardened one; the client settings that made the difference.
> **Success criteria:** you (a) identify the rogue from an anomaly and state the detection method's limit, **and** (b) show a **hardened client that does not auto-join the twin** which a vulnerable client joined, with evidence. Passing by **demonstrating the defence works** (the hardened client declines) is the intended outcome — no attack need "succeed" beyond the vulnerable-client baseline.
> **Troubleshooting:** detector shows nothing (wrong channel/band, sensor not in monitor mode — [03.4](../module-03/lesson-04.md)); hardened client still joins (auto-join not actually disabled, or a stale open PNL entry remains — prune it); can't tell rogue from real (clone matches BSSID/signal — note the detection limit and rely on client policy); no `AP-STA-CONNECTED` on the vulnerable client (SSID/security mismatch with its saved profile).
> **Cleanup:** stop the detector, `hostapd`/twin, and helpers; forget synthetic SSIDs on test clients; `../../labs/common/reset-lab.sh`; on V, `../../labs/common/hwsim-down.sh`.

> [!WARNING]
> Detection is passive, but standing up the twin to test against transmits — use **synthetic** SSIDs and **owned** clients only, minimum TX power, on your allowlist ([00.3](../module-00/lesson-03.md)). Never advertise a real SSID even "just to test detection."

## Exercise

You are hardening a small office after an assessment found a personal device auto-joined a rogue of the open guest SSID. The office wants a short, prioritised plan and a way to prove it worked. Draft the detection measures, the client controls (mapped to the attacks they stop), and the exact before/after test you would run to demonstrate the fix — including what evidence constitutes a pass.

<details>
<summary>Hint</summary>

Separate "know a rogue is present" (detection) from "clients won't join it" (prevention), and remember prevention is what removes the impact because the weakness is client-side. Map each control to the specific attack it defeats, and make the proof the same twin presented to a client before and after hardening.
</details>

<details>
<summary>Reference answer</summary>

**Detection:** deploy a passive WIDS/sensor (e.g. Kismet or the managed WLAN's built-in) to alert on your SSIDs appearing on unexpected BSSIDs/channels and on signal anomalies; baseline the authorised BSSIDs/channels. State the limit: a clone matching BSSID and signal may evade detection, so detection supports but does not replace client policy. **Client controls (mapped):** disable **auto-join for open/guest networks** and **prune stale open PNL entries** (defeats silent evil twin, 09.2, and known-beacon, 09.4); keep **OS current** and **MAC randomisation on** (frustrates KARMA/MANA profiling, 09.4); prefer **network-identity validation** — move sensitive access to WPA3-SAE or enterprise with server-cert validation so a cloned SSID is insufficient (09.2, Module 11); **user awareness** that no legitimate network demands a Wi-Fi password via a pop-up and that certificate warnings mean stop (defeats the captive portal, 09.3, which no client setting alone stops). Consider moving guest off open (OWE improves confidentiality but does not stop an active twin). **Before/after test:** present a synthetic-SSID twin to the affected device *before* hardening — it auto-joins (`AP-STA-CONNECTED`, the baseline) — then apply the controls and present the identical twin again. **Pass evidence:** the hardened device does **not** auto-join (no `AP-STA-CONNECTED`; it prompts or declines), captured from the AP log and the client state, with OS/version recorded. The pass is demonstrating the defence works, not achieving any attack.
</details>

## References

- [NIST SP 800-153 — Securing WLANs](https://csrc.nist.gov/pubs/sp/800/153/final) — rogue-AP detection and WLAN client/monitoring guidance.
- [Kismet documentation](https://www.kismetwireless.net/docs/readme/intro/kismet/) — passive detection and alerting used for the WIDS role.
- [SpecterOps — Modern Wireless Tradecraft Pt II](https://specterops.io/blog/2019/11/04/modern-wireless-tradecraft-pt-ii-mana-and-known-beacon-attacks/) — why hardened, current-OS clients resist rogue APs.
- [09.2 · Evil twin — conditional on client behaviour](lesson-02.md) — the client controls measured here in full detail.

## What you should now be able to do

- Detect a rogue AP from BSSID/SSID and signal anomalies and from client policy, and state the limits of each method.
- Apply the client controls — disable auto-join, prune the PNL, validate network identity, keep MAC randomisation on — and map each to the attack it defeats.
- Measure and evidence the vulnerable-versus-hardened difference, passing by demonstrating that the hardened client does not auto-join the twin.
