---
id: "04.4"
module: 4
minutes: 18
practice_minutes: 15
prerequisites: ["04.1"]
objectives:
  - Explain wardriving and how WiGLE maps networks from GPS-tagged passive observations.
  - Distinguish lawful passive observation of network metadata from unlawful interception of content.
  - Apply owned-lab framing and a jurisdiction check before any active step, and handle collected metadata responsibly.
volatility: concept
sources:
  - title: "WiGLE — Wireless Geographic Logging Engine (about and map)"
    url: https://wigle.net/
  - title: "IEEE 802.11-2020 standard (beacon/probe metadata vs frame payload)"
    url: https://standards.ieee.org/ieee/802.11/7028/
last_verified: "2026-10-01"
---

# 04.4 · Wardriving, WiGLE, and recon ethics

Scaling discovery from one room to a whole area is wardriving: moving through space while passively logging the networks you hear, each tagged with where you heard it, so a map of access points builds up — and WiGLE is the public database that aggregates these observations worldwide. This lesson explains how that mapping works, draws the line between passively observing network metadata and unlawfully intercepting content, and insists on owned-lab framing and a jurisdiction check for anything beyond listening.

## Why this matters

Wardriving sits exactly on the boundary this course keeps returning to: it can be done entirely passively and lawfully, and it can also drift into collecting data about people and places in ways that are legally and ethically fraught depending on where you are and what you keep. A tester who understands the distinction can use mapping legitimately — site survey, finding your own APs, understanding coverage — and avoid the version that gets people into trouble. WiGLE is also simply a tool you will meet, and knowing what it does and does not contain keeps you from either over-trusting it or misusing it.

## Learning objectives

- Explain **wardriving** and how **WiGLE** maps networks from GPS-tagged passive observations.
- Distinguish lawful **passive observation of metadata** from unlawful **interception of content**.
- Apply **owned-lab framing** and a **jurisdiction check** before any active step, and handle collected metadata responsibly.

## Prerequisites

- [04.1 · Passive versus active discovery](lesson-01.md) — the passive/active distinction and the interception point are the whole basis of this lesson's ethics.

## Concept

### How it works — wardriving and WiGLE

**Wardriving** means surveying wireless networks while moving through an area — on foot, by bike, or in a vehicle — with a scanner (a phone app, or a laptop running Kismet) logging every AP and client it hears together with a **GPS** position. Crucially, what is logged is the same **metadata** a passive survey sees: BSSID, SSID, channel, and advertised security ([04.2](lesson-02.md)) — plus the coordinates where it was heard. It does **not** require joining any network or decoding any traffic.

The GPS records **where the scanner was**, not where the AP is. A single observation only says "this BSSID was audible from roughly here." With many observations of the same BSSID from different positions, and factoring signal strength, the location of the AP itself can be **estimated by triangulation** — which is how a map ends up with a dot for each network.

**WiGLE** (Wireless Geographic Logging Engine) is a long-running public project that aggregates these observations from many contributors into a searchable world map; it has indexed hundreds of millions of networks since the early 2000s. It stores network metadata — coordinates, SSID, BSSID, and encryption type — and explicitly does **not** store usernames, passwords, or the contents of traffic. It is used for site survey, coverage and security analysis, research, and hobby mapping.

### Why the distinction matters — metadata versus content

The legal and ethical line is the one from [04.1](lesson-01.md), sharpened:

- **Observing metadata** — reading the beacon/probe fields an AP broadcasts to the world (its existence, name, channel, security) and noting where you heard it — is passive reception of information that was transmitted openly. In many jurisdictions this is treated very differently from interception, and it is what wardriving and WiGLE deal in.
- **Intercepting content** — capturing and examining the *payload* of traffic (what devices are actually sending) — is interception and is restricted or unlawful in many places even without decryption, and certainly if you decrypt. Monitor mode captures content too, so a wardrive that saves full packet payloads of other people's networks is a different and far riskier act than one that logs metadata.

"Passive" protects you from the interference and detectability problems, but **it does not by itself make collecting and keeping data about others lawful or ethical**. Laws on this vary widely by country and even region — some treat open-network metadata collection as benign, others restrict it, and rules on retaining and publishing location-tagged data about identifiable networks differ again. The honest guidance is: know your jurisdiction before you collect, and err toward metadata-only, minimal retention, and your own equipment.

### Owned-lab framing for anything active

Wardriving as described is passive. The moment a step transmits — a directed probe to resolve a hidden SSID, any attempt to associate, any deauth — you are back under the full owned-equipment rule: those steps target **only** networks you own, with synthetic credentials, at minimum transmission ([00.3](../module-00/lesson-03.md)). There is no "it's just mapping" exception for transmitting at networks you do not own. In this course, mapping exercises use a **supplied dataset** or your **own** APs; you do not conduct an active wardrive against strangers' networks.

> [!IMPORTANT]
> Finding a network on WiGLE or in your own wardrive tells you it exists and roughly where — nothing more. It is not authorisation to test it, connect to it, or probe it. Authorisation comes from owning the equipment or holding written permission ([00.3](../module-00/lesson-03.md)); a public map is not permission.

## Hands-on

This lesson supports the recorded-data path only: there is no transmit step, and you work from a supplied, sanitised dataset rather than collecting real people's networks.

### Guided walkthrough — read a wardrive dataset and reason about it

1. **(R)** Open `captures/wardrive-sample.csv` from `labs/module-04/` — a small, **synthetic** wardrive log (BSSID, SSID, channel, security, lat/long, signal) generated for this course. Confirm it contains only metadata: no payloads, no credentials.
2. **(R)** Pick one BSSID observed from several positions. Reason about how multiple observations plus signal strength would let a tool estimate the AP's location, and why a single row cannot.
3. **(R)** Classify each row's security from its encryption field ([04.2](lesson-02.md)) and note what the dataset reveals about the area (density, common security) without identifying any individual.
4. **(R)** Write two sentences on what would change — legally and ethically — if this log had instead captured full packet payloads from those networks, and why metadata-only was the right choice.

### Lab

> [!NOTE]
> **Lab paths:**
> R (read `wardrive-sample.csv` — no hardware, no transmission; proves you can interpret GPS-tagged network metadata and reason about location estimation and the metadata/content line. It does **not** involve or prove any live collection.)
> **Start state:** the supplied synthetic dataset in the module zip; no radio needed.
> **Duration:** ~15 min (R).
> **Artifacts:** a short written analysis — per-row security classification, an explanation of why multiple observations are needed to place an AP, and the two sentences on metadata vs content.
> **Troubleshooting:** rows look identical (confirm you are comparing the repeated BSSID across different lat/long, not different BSSIDs); unsure if a field is content (it is not — the dataset is metadata-only by construction, [04 lab README](../../labs/module-04/)).
> **Cleanup:** none — the dataset is synthetic and carries no real personal data. If you ever run a real survey on your own equipment, retain only metadata and delete location logs you do not need.

## Exercise

A learner, keen to practise, proposes: "I'll drive around my neighbourhood with Kismet capturing everything in full — payloads included — and upload it all to a public map, since wardriving is passive and therefore legal." Identify the three distinct mistakes (one about what to capture, one about what passive guarantees, one about publishing) and state how to do a defensible version instead.

<details>
<summary>Hint</summary>

Separate three things: capturing *metadata* versus capturing *payload content*; whether "passive" settles the legality of collecting and keeping data about others; and the extra step of *publishing* identifiable, location-tagged data. Then recall what WiGLE itself deliberately does not store.
</details>

<details>
<summary>Reference answer</summary>

Three mistakes. (1) *What to capture:* "capturing everything in full — payloads included" crosses from metadata observation into intercepting the content of other people's traffic, which is restricted or unlawful in many jurisdictions regardless of being passive; a defensible survey logs metadata only (BSSID, SSID, channel, security, position), as WiGLE itself does. (2) *What passive guarantees:* passive means no transmission, which removes interference/detectability, but it does not by itself make collecting and retaining data about others lawful or ethical — that depends on jurisdiction and on what is kept. (3) *Publishing:* uploading identifiable, location-tagged data adds a separate privacy and legal exposure beyond collecting it. Defensible version: check local law first, collect metadata only, minimise and protect what you retain, prefer your own equipment, and do not publish payloads or anything that was unlawful to gather — and remember that finding a network never authorises testing it.
</details>

## References

- [WiGLE — Wireless Geographic Logging Engine](https://wigle.net/) — what the public map aggregates and what it deliberately does not store.
- IEEE 802.11-2020 — the broadcast beacon/probe metadata a passive survey reads, versus frame payload (`../../references/README.md`).
- [00.3 · Safety, containment, and the law](../module-00/lesson-03.md) — authorisation, interception, and the owned-equipment rule for any active step.
- [04.1 · Passive versus active discovery](lesson-01.md) — the metadata/content and passive/active distinctions this lesson builds on.

## What you should now be able to do

- Explain wardriving and how WiGLE estimates and maps AP locations from GPS-tagged passive metadata observations.
- Distinguish lawful passive observation of network metadata from unlawful interception of content, and know that passive does not by itself settle legality.
- Apply owned-lab framing and a jurisdiction check before any active step, handle collected metadata responsibly, and treat a map listing as information, not authorisation.
