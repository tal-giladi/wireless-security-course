---
id: "04.3"
module: 4
minutes: 20
practice_minutes: 20
prerequisites: ["04.2"]
objectives:
  - Explain how a client's probe requests can expose its Preferred Network List and why that is a privacy issue.
  - Describe how MAC randomisation changes what a passive observer can see and correlate.
  - Read a client's probed SSIDs from a capture and reason about evil-twin viability as conditional on client behaviour.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (probe request/response, active scanning)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Vanhoef et al. — Why MAC Address Randomization is not Enough (WiSec 2016)"
    url: https://papers.mathyvanhoef.com/wisec2016.pdf
last_verified: "2026-10-01"
---

# 04.3 · Clients, probe requests, and the PNL

Access points are the obvious targets, but the clients around them leak information of their own: as a device looks for networks it remembers, it can broadcast their names in probe requests, exposing a Preferred Network List that is both a privacy problem and the seed of later client-side attacks. This lesson explains how the PNL surfaces in probe requests, how MAC randomisation changes what a passive observer can actually see, and why any evil-twin conclusion drawn from this data is conditional on how a specific client behaves.

## Why this matters

The rogue-AP and evil-twin work in Module 9 does not succeed against "clients" in the abstract — it succeeds against a client whose behaviour makes it succeed, and the evidence for that behaviour is gathered here. A device that actively probes for a remembered open network, or auto-joins any SSID matching its PNL, is a very different target from one that scans passively and validates before joining. Reading probe requests tells you which you are dealing with. It is also a privacy lesson in its own right: the same frames that inform an attacker reveal where a person's device has been, which is exactly why client vendors changed the behaviour.

## Learning objectives

- Explain how **probe requests** can expose a client's **PNL** and why that is a privacy concern.
- Describe how **MAC randomisation** changes what a passive observer can see and correlate.
- Read a client's probed SSIDs from a capture and reason about **evil-twin viability as conditional on client behaviour**.

## Prerequisites

- [04.2 · airodump-ng and Kismet](lesson-02.md) — you must be able to read the stations table and a client's Probe field before you reason about what those probes reveal.

## Concept

### How it works on the wire — the PNL in probe requests

When a client actively scans, it sends **probe request** frames ([04.1](lesson-01.md)). Historically, devices sent **directed** probe requests naming each network in their **Preferred Network List** — the saved networks the device remembers and is willing to rejoin — so a passive listener could read, straight off the air, the names of networks that device had connected to before: a home SSID, an employer's SSID, a named café, a hotel. Because probe requests are unencrypted management frames, no association and no key is needed to collect them; monitor-mode reception is enough. That list is a fingerprint of the device's history and movements, which is the privacy problem.

Two SSID histories make a device trackable and sometimes locatable: unusual or unique names (a personal router SSID, a corporate SSID) identify an individual or organisation, and the *set* of names together is distinctive even when each is common.

### Why the weakness exists — and what changed it

Directed probing existed because it is fast: naming the network you want gets a quick, specific response and finds hidden SSIDs. The privacy cost was not designed in — it was a side effect of broadcasting your history. Modern client operating systems changed two things:

- **MAC randomisation.** Instead of probing with the device's real, globally-unique MAC, modern clients use a **randomised** MAC for probing (and often a per-network randomised MAC once associated). A passive observer can no longer assume a stable address identifies one device across time and place, which breaks naive tracking that keyed on the MAC.
- **Fewer directed probes.** Many current clients now prefer **broadcast (wildcard) probe requests** or lean on passive scanning, so they no longer spray their saved SSID names into the air as a matter of course. When they do probe by name, it is often reduced to specific cases.

Neither change is a complete fix. Randomisation is **not standardised**, so implementations differ by OS and version, and research has shown randomised probes still carry static fields and timing/signal characteristics that can re-identify or cluster a device. Treat "the client randomises, so it is private" as a claim to test, not a given — and mark the exact behaviour of a given OS/version as something you verified, not assumed (this is why the lesson's client-behaviour specifics are `volatility: concept` in principle but must be checked per device).

### How a tester recognises it — and the link to evil twins

In a capture you read a client's exposed PNL from its **directed probe requests**: each names an SSID the device is looking for. A client that directs probes at an **open** or **WPA2-PSK** network it remembers, and that auto-joins on match, is a candidate for an evil twin advertising that same SSID (Module 9) — *because of how that client behaves*. A client that only broadcast-probes, randomises aggressively, and validates the network before joining gives you far less and resists the same attack. So the correct form of every conclusion here is **"a client that does X is exposed to Y,"** with the observed behaviour as the evidence — never "clients leak their PNL" as a blanket fact.

> [!IMPORTANT]
> Collecting probe requests means recording other people's devices. Even passively, the PNL is personal data about where someone's device has been. In this course you observe **only** your own controlled lab clients with synthetic saved networks; you do not collect bystanders' probes ([00.3](../module-00/lesson-03.md)).

## Hands-on

This lesson supports all three paths. **R** proves you can read a client's probed SSIDs from a supplied capture; **V** proves you can generate and observe probe behaviour with a controlled supplicant; **P** is the only path that proves real over-the-air probe capture from your own devices and the randomisation behaviour of real hardware.

### Guided walkthrough — read a PNL and compare two clients

1. **(R)** Open `captures/probe-requests.pcapng` from `labs/module-04/` and filter for probe request subtype. For the lab client with a stable MAC, list the directed SSIDs it probes — that is its exposed PNL.
2. **(R)** Compare with the second client in the capture that uses randomised MACs and broadcast probes: note how much less you can attribute to one device, and which static fields remain.
3. **(V/P)** Configure your own lab client (`wpa_supplicant` or an owned device) with two synthetic saved networks (`LAB-HOME`, `LAB-CAFE`). Capture its scanning with airodump-ng/Kismet and read what it reveals.
4. **(V/P)** Toggle the device's MAC-randomisation / privacy setting (where available) and recapture. Record the difference in what a passive observer can see, and note the exact OS/version you tested.

### Lab

> [!NOTE]
> **Lab paths:**
> R (read `probe-requests.pcapng` — no hardware; proves you can extract a client's probed SSIDs and compare randomised vs stable behaviour, not that you captured it).
> V (`mac80211_hwsim` + `wpa_supplicant` as a controlled client — proves you can generate and observe probe/scan behaviour of a configured supplicant; does **not** reproduce a real phone's OS-specific randomisation, directed-vs-broadcast policy, or real RF).
> P (owned adapter in monitor mode + your own phone/laptop as the client — the only path that proves real OS randomisation behaviour and over-the-air probe capture).
> **Start state:** path built ([03.x](../module-03/lesson-01.md)); your own lab client holding synthetic saved networks (`LAB-HOME`, `LAB-CAFE`); allowlist written and limited to your own devices.
> **Duration:** ~20 min (V/P) / ~10 min (R).
> **Artifacts:** a list of the directed SSIDs your own client exposed; a before/after note on MAC randomisation (with the tested OS/version); a short statement of whether an evil twin for one of those SSIDs would be viable against *that* client and why.
> **Troubleshooting:** no directed probes seen (modern clients broadcast-probe by default — this is a valid result, note it; force a directed scan only on your own device if you must); randomised MAC changes every scan (expected — that is the point); captured SSIDs from a device you do not own (stop — out of scope, discard).
> **Cleanup:** stop capture; on V run `labs/common/hwsim-down.sh`; delete captured probe data (it concerns real devices even when they are yours); remove the synthetic saved networks from the test client.

> [!CAUTION]
> Probe-request capture records personal data about real devices. Capture **only** your own controlled clients with synthetic saved networks, and delete the data after the exercise. Never collect bystanders' probe requests ([00.3](../module-00/lesson-03.md)). LAB TARGET vs REAL NETWORK: the only clients in scope are devices you own.

## Exercise

A tester captures probe requests in a lab and writes in the report: "The target's clients leak their full network history in probe requests, so an evil twin impersonating any of those SSIDs will capture them." Two separate claims in that sentence are too strong given modern client behaviour. Identify both and rewrite the conclusion in the correct conditional form.

<details>
<summary>Hint</summary>

Think about what a current phone actually transmits when it scans, and whether a stable MAC let the tester attribute "full history" to one device. Then think about what has to be true of a client for an evil twin to actually capture it — is advertising the SSID sufficient?
</details>

<details>
<summary>Reference answer</summary>

First over-claim: "leak their full network history." Modern clients largely broadcast-probe and randomise their MAC, so many devices reveal little or no directed PNL, and a randomised MAC prevents attributing a stable "full history" to one device — what you see is partial and often unlinkable. Second over-claim: "an evil twin ... will capture them." Evil-twin success is conditional on the client's behaviour — whether it remembers that SSID, auto-joins on match, and fails to validate the network — not merely on the attacker advertising the name. Correct conditional form: "A lab client that directs probes at remembered open/PSK SSIDs and auto-joins without validation is exposed to an evil twin advertising one of those SSIDs; a client that broadcast-probes, randomises its MAC, and validates before joining reveals little here and resists the same attack. Which applies must be established per client (and per OS/version) from the capture."
</details>

## References

- IEEE 802.11-2020 — probe request/response frames and active scanning (`../../references/README.md`).
- [Vanhoef et al. — Why MAC Address Randomization is not Enough (WiSec 2016)](https://papers.mathyvanhoef.com/wisec2016.pdf) — static fields and signatures that survive randomisation.
- [04.1 · Passive versus active discovery](lesson-01.md) and [04.2 · airodump-ng and Kismet](lesson-02.md) — where probe data is captured and read.

## What you should now be able to do

- Explain how directed probe requests expose a client's PNL and why that is a privacy concern.
- Describe how MAC randomisation and broadcast probing change what a passive observer can see and correlate, and why they are not a complete fix.
- Read a client's probed SSIDs and state evil-twin viability as a claim conditional on that client's observed behaviour.
