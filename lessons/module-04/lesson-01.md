---
id: "04.1"
module: 4
minutes: 18
practice_minutes: 20
prerequisites: ["03.1"]
objectives:
  - Distinguish passive discovery (listening only) from active discovery (probing) at the frame level.
  - Weigh the detectability and containment trade-offs of each and choose the quieter method by default.
  - Carry out a discovery pass on the path you built, transmitting the minimum the task needs.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (scanning — passive and active)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "aircrack-ng — airodump-ng documentation (capture and channel behaviour)"
    url: https://www.aircrack-ng.org/doku.php?id=airodump-ng
last_verified: "2026-10-01"
---

# 04.1 · Passive versus active discovery

Reconnaissance is the first thing you do on an engagement and the first place you can give yourself away, so the choice between listening and probing is a decision you make deliberately on every pass. This lesson separates passive discovery — receiving beacons and existing traffic while your radio transmits nothing — from active discovery, where you send probe requests to draw out replies, and ties both back to the minimum-transmission and containment discipline from Module 0 and the scanning mechanics from Module 1.

## Why this matters

Everything later in the course keys off a target list you build here: which BSSIDs exist, on which channels, running which security. If you reach for active probing by reflex you transmit frames that a defender's wireless IDS can log, that reach networks you do not own, and that in some jurisdictions edge toward interference you did not intend. If you listen first, you often learn everything you need while emitting nothing at all. Knowing exactly which part of discovery is silent and which is not is what lets you scope a pass to the quietest method that still answers the question.

## Learning objectives

- Distinguish **passive discovery** (receive only) from **active discovery** (probe and listen) at the frame level.
- Weigh the **detectability and containment** trade-offs and default to the quieter method.
- Run a discovery pass on your path and transmit no more than the task requires.

## Prerequisites

- [03.1 · Choosing your path](../module-03/lesson-01.md) — you must know which path (R, V, or P) you built and what it can and cannot do before you run a discovery pass on it.

## Concept

### How it works on the wire

Discovery reuses the two scanning methods a client uses to find a network ([01.4](../module-01/lesson-04.md)), turned to the tester's purpose.

**Passive discovery.** Your radio sits in monitor mode on a channel and *receives*. Access points broadcast **beacon** frames several times a second advertising SSID, channel, supported rates, and — in the RSN element — their security (WPA2, WPA3-SAE, OWE, PMF). You also hear existing **probe requests/responses**, data frames, and management traffic that are already in the air. You transmit nothing. A listener cannot be detected by its reception, so passive discovery is the lowest-footprint recon there is; its cost is time, because you only learn what others happen to send while you listen, and a quiet AP with no clients may take seconds to beacon a full picture.

**Active discovery.** Your radio *transmits* **probe request** frames — broadcast (wildcard SSID) or directed at a named SSID — and nearby APs answer with **probe responses**. This is faster and can surface an AP that is beaconing rarely, and directed probes are the standard way to confirm a **hidden SSID** (one whose beacon omits the name) once you learn the name from an associating client. The cost is that you are now a transmitter: your probes are logged frames with your (possibly randomised) MAC, they reach every AP in range including ones you do not own, and a wireless IDS can flag an unknown station probing the environment.

### Detectability and containment

The Module 0 rule — a private subnet does not contain radio ([00.3](../module-00/lesson-03.md)) — governs the choice here. Passive discovery radiates nothing, so it cannot leak past your antenna and cannot disturb a neighbour's network; its only legal exposure is the interception question (what you are allowed to *record*), not an interference one. Active discovery transmits, so it is subject to minimum-necessary-transmission: probe only when listening did not answer the question, prefer a directed probe for a specific owned SSID over spraying wildcard probes at everything in range, and keep it on the channel and for the window you scoped.

> [!IMPORTANT]
> "Passive" means your radio does not transmit — it does **not** mean you may record anything you can hear. Monitor mode receives every network on the channel, and capturing traffic from networks you do not own can be unlawful interception regardless of how quietly you did it. Point your capture at your own allowlisted targets ([00.3](../module-00/lesson-03.md)).

### Why a tester recognises the difference

On a capture you tell the two apart by who transmitted: a **beacon** or **probe response** is the AP talking; a **probe request** from your station's MAC is *you* talking. If your recon frames appear in your own capture, you were active. A clean passive pass contains beacons, other parties' probes, and data — but none of your own transmissions. This is also how a defender classifies you, so it is worth being able to read your own footprint the way their IDS would.

## Hands-on

This lesson supports all three paths. **R** proves you can read who transmitted in a supplied capture and classify a pass as passive or active; **V** proves you can run discovery against simulated radios and see the method's frames; **P** is the only path that proves real passive reception and real probing over the air against your own equipment.

### Guided walkthrough — classify a pass, then run a quiet one

1. **(R)** Open `captures/discovery-passive.pcapng` from the module zip (`labs/module-04/`) in Wireshark. Filter for management frames and confirm you see beacons and others' probe requests but **no** probe request bearing your own capture station's MAC — this is a passive pass.
2. **(R)** Open `captures/discovery-active.pcapng` and find the probe requests sent *from* the capturing station and the probe responses they drew back. Note how the directed probe names an SSID and the response confirms it.
3. **(V/P)** Put your interface in monitor mode (built in [03.3](../module-03/lesson-03.md)/[03.4](../module-03/lesson-04.md)) and run a **passive** `airodump-ng` pass on your lab channel. Watch your own allowlisted AP appear from its beacons alone; you sent nothing.
4. **(V/P)** Only if a passive pass left a question (e.g. a hidden SSID on your own AP), send a single directed probe for *that owned SSID* and confirm the response. Stop.

### Lab

> [!NOTE]
> **Lab paths:**
> R (read `discovery-passive.pcapng` and `discovery-active.pcapng` — no hardware; proves you can classify a pass by who transmitted, not that you captured it).
> V (`mac80211_hwsim` + `hostapd` for a lab BSS — proves you can drive passive and active discovery and observe the frames; does **not** reproduce real RF, range, interference, or hardware monitor behaviour).
> P (owned adapter in monitor mode + your own AP — the only path that proves real passive reception and real probing over the air).
> **Start state:** your chosen path built and verified ([03.x](../module-03/lesson-01.md)); for V/P an owned/simulated AP beaconing a synthetic SSID (`LAB-RECON`) on a known channel; target allowlist written ([00.3](../module-00/lesson-03.md)).
> **Duration:** ~20 min (V/P) / ~10 min (R).
> **Artifacts:** an annotated note classifying each supplied capture as passive or active with the frame that proves it; (V/P) an `airodump-ng` passive capture of your own AP, and at most one logged directed probe for your own hidden SSID.
> **Troubleshooting:** no beacons seen (wrong channel, or AP on a different band — confirm with a full scan); your own probes missing from a "passive" capture is correct, not a fault; monitor mode unavailable (recheck [03.4](../module-03/lesson-04.md)).
> **Cleanup:** stop `airodump-ng`; on V run `labs/common/hwsim-down.sh`; nothing persistent is created. On P you transmitted at most one directed probe to your own AP — note it in your log.

> [!WARNING]
> The active step transmits. Owned lab equipment only: probe **only** a synthetic SSID on an AP you own, at minimum TX power on your scoped channel, and never spray wildcard probes across networks you do not own ([00.3](../module-00/lesson-03.md)). LAB TARGET vs REAL NETWORK: `LAB-RECON` is yours; everything else on the channel is out of scope and must not be probed.

## Exercise

A teammate says: "Passive recon is completely safe and legal because the radio never transmits, so I left monitor mode capturing the whole channel in a shared office all afternoon to build a thorough target list." Identify the two separate issues in that reasoning — one about what "passive" does and does not protect, and one about scope — and state what a defensible passive pass would have looked like instead.

<details>
<summary>Hint</summary>

Separate *transmission* from *recording*. Not transmitting removes the interference and detectability problem, but it says nothing about whether you were allowed to capture the traffic you heard. Then ask whose networks were on that shared channel, and which ones were on the allowlist.
</details>

<details>
<summary>Reference answer</summary>

Two distinct problems. First, "passive = safe" conflates not transmitting with not intercepting: monitor mode receives every network on the channel, so capturing a whole shared office all afternoon almost certainly recorded traffic from networks the tester does not own, which can be unlawful interception no matter how silent the radio was ([00.3](../module-00/lesson-03.md)). Second, scope: a shared office channel carries many out-of-scope networks, so an untargeted capture breaks the allowlist discipline. A defensible passive pass would be bounded to the allowlisted BSSIDs/SSIDs, kept only as long as needed to enumerate those targets, and filtered/retained accordingly — passive as to transmission, but still disciplined as to what is recorded and kept.
</details>

## References

- IEEE 802.11-2020 — passive and active scanning procedures (`../../references/README.md`).
- [aircrack-ng — airodump-ng](https://www.aircrack-ng.org/doku.php?id=airodump-ng) — the capture tool used for the discovery pass (detailed in [04.2](lesson-02.md)).
- [00.3 · Safety, containment, and the law](../module-00/lesson-03.md) — minimum transmission, allowlists, and the interception distinction.
- [01.4 · Joining a network](../module-01/lesson-04.md) — the beacon/probe scanning mechanics this lesson turns to recon.

## What you should now be able to do

- Tell passive discovery from active discovery by which frames your own radio transmitted.
- Explain why passive recon removes the interference/detectability risk but not the interception question, and why active recon is governed by minimum transmission.
- Run a discovery pass on your path that defaults to listening and probes only your own targets when listening leaves a gap.
