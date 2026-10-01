---
id: "13.1"
module: 13
minutes: 25
practice_minutes: 30
prerequisites: ["00.3"]
objectives:
  - Build a wireless target allowlist from BSSIDs and SSIDs and state why everything else is out of scope.
  - Explain why radio ignores property lines and what that means for scoping collateral networks and clients.
  - Produce a written authorisation sheet with transmission limits, time windows, stop conditions, and rules of engagement.
volatility: concept
sources:
  - title: "NIST SP 800-115 — Technical Guide to Information Security Testing and Assessment"
    url: https://csrc.nist.gov/publications/detail/sp/800-115/final
  - title: "Penetration Testing Execution Standard (PTES) — Pre-engagement Interactions"
    url: http://www.pentest-standard.org/index.php/Pre-engagement
last_verified: "2026-10-01"
---

# 13.1 · Scoping and authorisation for wireless

Every engagement in this course targets equipment you own, but the habit it builds is the one that separates a professional test from a crime: before anything transmits, you write down exactly what is in scope, who authorised it, and the limits you will not cross. Wireless makes this harder than wired testing because radio does not respect the boundaries on a scope document — a signal crosses walls and property lines whether or not the paperwork says so. This lesson turns the authorisation habit from Module 0 into a professional scoping process for a wireless engagement.

## Why this matters

On a wired test, scope is mostly an IP range: packets go where you route them, and a firewall contains your mistakes. On a wireless test, the medium is shared with everyone in range. A deauthentication frame, a probe, or a rogue beacon does not stop at the client's door — it reaches the coffee shop downstairs and the flats next door. That means a wireless scope has to answer a question a wired scope never asks: *what happens to the networks and clients you did not list but will inevitably touch?* Getting scoping and authorisation right is what keeps a legitimate test from becoming unlawful interception or interference (Lesson 00.3), and it is the first section a good report is judged on. A finding recovered outside scope is not a finding; it is a liability.

## Learning objectives

- Build a wireless target allowlist from specific BSSIDs and SSIDs, and state why everything not listed is out of scope.
- Explain why radio crosses property lines and how to scope the collateral networks and clients a wireless test unavoidably observes.
- Produce a written authorisation sheet covering transmission limits, time windows, stop conditions, and rules of engagement, reusing the course template.

## Prerequisites

- Lesson 00.3 — safety, containment, and the law. This lesson assumes you already know that a private subnet does not isolate radio, and that the only authorised targets in this course are equipment you own.

## Concept

This is a process lesson. **LAB TARGET vs REAL NETWORK:** you practise scoping against your own lab, but the process is written so it transfers unchanged to an authorised real engagement. Nothing here authorises testing a network you do not own.

### The control or process

A wireless engagement is scoped in five parts, each of which becomes a section of the authorisation sheet and later a section of the report (see the [scope & authorisation template](../../templates/authorisation-template.md) and the [report template](../../templates/report-template.md)).

**1. The target allowlist.** Scope is defined positively: a table of the exact networks you may touch, identified by **both SSID and BSSID**. SSID alone is ambiguous — several APs, yours and a neighbour's, can advertise the same name, and an evil-twin exercise deliberately clones one — so the BSSID (the AP's MAC) is what actually pins a target. List the band and channel too, because that is where you will be transmitting and listening. Everything not in the table is out of scope and must not be probed, deauthenticated, or captured, even if you can see it.

**2. The authorisation itself.** Who owns the equipment, who authorised the test, the date, and the expiry. For this course the owner is you; in a real engagement this is a signed statement of work, and an engagement without one does not start. The authorisation names the allowlist so there is no later argument about what "the network" meant.

**3. Transmission limits.** Because radio leaks, you constrain what you radiate: the channel(s) you will use, the **lowest TX power that works**, and any directional antenna, attenuation, or RF shielding. Prefer the virtual (`mac80211_hwsim`) path for transmit-heavy work where real RF is not the point. These limits are part of scope, not an afterthought — they bound the collateral in point 5.

**4. Time window.** When the test may run. A wireless test run during business hours in a shared building touches far more bystander devices than the same test at 02:00; the window is a scoping decision with a safety consequence.

**5. Stop conditions and rules of engagement.** The explicit triggers that end the test immediately: a device **not** on the allowlist associates to your rogue AP or is disrupted, you observe interference with a production or neighbouring network, or the time window ends. Rules of engagement also record who to contact, what is explicitly forbidden (e.g. no attacks that would knock a real client offline), and how evidence containing incidental third-party data is handled.

### Why wireless scope is different — radio ignores property lines

The defining problem of wireless scoping is that **you cannot confine your test to the allowlist by intent alone**. Three kinds of collateral are unavoidable and must be addressed in scope rather than discovered mid-test:

- **Collateral networks.** Monitor mode and a survey capture *everything* on a channel — your neighbours' beacons, their clients' probe requests, their traffic metadata. You will observe out-of-scope networks simply by listening. Scope must say what you do with that incidental data: you do not act on it, you do not report it as a finding, and you minimise or redact it in evidence.
- **Collateral clients.** A deauth aimed at "your" client, or a rogue AP advertising a common SSID, can affect any device in range that happens to behave the way the attack exploits. This is exactly why transmission limits and stop conditions exist, and why PMF-aware, controlled-client designs (used throughout the attack modules) matter: they shrink the blast radius.
- **The shared medium itself.** Even a perfectly aimed test consumes airtime and can interfere. In a dense building, "in scope" is never fully isolated from "in range."

The professional move is to **scope the collateral, not pretend it away**: state in the authorisation sheet that incidental observation of neighbouring networks will occur, that no action will be taken against them, that transmission is minimised and shielded/virtual where practical, and that the test stops the moment an out-of-scope device is affected. A scope document that claims a wireless test only touches the listed BSSIDs is wrong on the physics, and a client who signs it has been misled.

## Hands-on

### Guided walkthrough — scope an owned-lab engagement

A paper exercise; no radio, no attack. You will fill in the authorisation template for a small lab you own (one AP, one laptop, one phone — all yours is enough).

1. Open the [scope & authorisation template](../../templates/authorisation-template.md) and copy it into your notes.
2. **Allowlist:** list each AP you own by SSID *and* BSSID, with its band and channel. Mark each "in scope: yes." Write one line stating that every other network you observe is out of scope.
3. **Authorisation:** fill in owner (you), authorised-by, date, and expiry. Note where a real engagement's signed statement of work would go.
4. **Transmission limits:** choose the channel, set the lowest TX power you will use, and note whether you will use the virtual path or a shield for transmit-heavy exercises.
5. **Time window and stop conditions:** pick a window, then write the three stop conditions in your own words, including the out-of-scope-device trigger.
6. **Collateral statement:** add two or three sentences acknowledging that neighbouring networks and clients will be observed incidentally, and stating what you will and will not do about them.

### Lab

> [!NOTE]
> **Lab paths:** R — produce a written authorisation sheet for an owned-lab scenario (no hardware, nothing transmitted). It proves you can scope an engagement and reason about wireless collateral; it does **not** prove any live capture, injection, or AP-mode work — those are credited only on the V/P paths in the attack modules.
> **Start state:** the [authorisation template](../../templates/authorisation-template.md); a note of the equipment you own (or a lab scenario you invent, all owned).
> **Duration:** ~30 min.
> **Artifacts:** a completed scope & authorisation sheet — allowlist (SSID + BSSID + band/channel), authorisation block, transmission limits, time window, stop conditions, and a collateral statement. You will reuse this sheet in Lesson 13.2 and in both capstones.
> **Success criteria:** every allowlist entry has a BSSID (not just an SSID); the collateral statement explicitly acknowledges out-of-scope networks/clients and says no action is taken against them; at least one stop condition is the out-of-scope-device trigger.
> **Cleanup:** none (paper). Restate: offensive work in later modules targets only equipment you own, with this sheet filled in first.

## Exercise

A client asks you to test "the guest Wi-Fi, SSID `Acme-Guest`" at their office, which occupies floors 3 and 4 of a twelve-storey shared building. They hand you a one-line scope: "SSID `Acme-Guest`, test everything." Identify at least three ways this scope is unsafe or ambiguous for a *wireless* test, and rewrite it into a defensible scope. Do not run anything — this is a scoping judgement exercise.

<details>
<summary>Hint</summary>

Think about what "SSID `Acme-Guest`" actually identifies on the air (how many APs broadcast it? could a neighbour or an evil twin?), and what your transmissions will reach in a shared twelve-storey building. Which parts of the authorisation sheet are missing entirely?
</details>

<details>
<summary>Reference answer</summary>

Problems with the one-line scope:

1. **SSID is not a target.** `Acme-Guest` may be broadcast by several APs across two floors; a neighbour could run the same name, and your own evil-twin exercise would add another. The scope must list the specific **BSSIDs** that belong to Acme, with band and channel, so there is no ambiguity about what you may touch.
2. **No collateral handling.** In a shared building your survey will capture many out-of-scope networks and clients, and any deauth or rogue AP can affect bystander devices on other floors. The scope says nothing about transmission limits, which guarantees you will exceed what the client actually consented to.
3. **No limits, window, or stop conditions.** "Test everything" has no TX-power ceiling, no agreed hours, and no trigger to stop if a third-party device is disrupted — exactly the gaps that turn a test into interference.

A defensible rewrite: an allowlist of Acme's specific BSSIDs (SSID + MAC + band/channel) on floors 3–4; authorisation signed by the client with a date and expiry; transmission limited to the lowest workable TX power on the target channel, with transmit-heavy work done virtually or shielded where possible; a time window (e.g. after hours) chosen to minimise bystander exposure; stop conditions including "stop if any device not on the allowlist associates or is affected, or if interference with a neighbouring network is observed"; and an explicit statement that neighbouring networks/clients will be observed incidentally, with no action taken against them and incidental data minimised in evidence.
</details>

## References

- NIST SP 800-115 — planning and rules-of-engagement for security testing (`../../references/README.md`).
- PTES — pre-engagement interactions and scoping (`../../references/README.md`).
- [Scope & authorisation template](../../templates/authorisation-template.md) and [report template](../../templates/report-template.md).
- Safety and law: [00.3](../module-00/lesson-03.md) — radio is not contained by the network.
- Glossary: target allowlist, rules of engagement, collateral networks, stop conditions (`../../glossary.md`).

## What you should now be able to do

- Build a wireless target allowlist keyed on BSSIDs (not just SSIDs) and justify why everything else is out of scope.
- Explain why a wireless test unavoidably touches collateral networks and clients, and scope that collateral honestly instead of ignoring it.
- Produce a complete written authorisation sheet — allowlist, authorisation, transmission limits, time window, stop conditions, and rules of engagement.
