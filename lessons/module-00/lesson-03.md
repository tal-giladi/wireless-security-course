---
id: "00.3"
module: 0
minutes: 20
practice_minutes: 10
prerequisites: ["00.1"]
objectives:
  - Explain why a private subnet does not isolate radio and what that means for lab safety.
  - Apply containment controls — target allowlists, controlled clients, minimum transmission, stop conditions, cleanup.
  - Frame wireless testing legally around authorisation, interception, interference, and local radio law.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wi-Fi Alliance — security"
    url: https://www.wi-fi.org/discover-wi-fi/security
last_verified: "2026-10-01"
---

# 00.3 · Safety, containment, and the law

Every offensive technique in this course transmits or receives radio, and radio does not respect the
boundaries you set in software. This lesson is the one you cannot skip: it teaches how to contain your
lab so your experiments reach only equipment you own, how to stay on the right side of the law, and the
habits that make the rest of the course safe to practise.

> [!WARNING]
> Deauthentication, beacons, and probe frames leave your wire and reach every device in radio range —
> including your neighbours' networks and devices you do not own. A VLAN, an air-gapped subnet, or a
> NAT boundary does **not** contain radio. Containment is a discipline, not a network setting.

## Why this matters

The single most common way a well-meaning learner causes real harm — or breaks the law — is assuming
that "it's just my lab" makes their transmissions private. It doesn't. A deauth flood knocks the
neighbours offline; a rogue AP lures a stranger's phone; a capture records traffic you had no right to
intercept. Getting containment and legality right in Module 0, before you own any attack tools, is what
lets you learn aggressively later without hurting anyone or exposing yourself to liability.

## Learning objectives

- Explain why a private subnet does **not** isolate radio, and name the real leakage paths.
- Apply the containment controls — allowlist, controlled client, minimum transmission, stop conditions,
  cleanup — to your own lab.
- Frame wireless testing legally around authorisation, interception, interference, and local radio law.

## Prerequisites

- [00.1 · What you'll learn, the three lab paths, and expectations](lesson-01.md). No technical setup is
  needed yet — this lesson is the ground rules you apply from the first lab onward.

## Concept

### Radio is not contained by the network

In wired labs, isolation is a topology problem: put the targets on their own switch or VLAN and nothing
escapes. Wireless breaks that model. The moment you transmit, your frames propagate through walls and
across property lines, and anything in range can receive them. Three consequences:

- **Denial of service leaks.** A deauth or disassociation aimed at "your" client can disrupt any device
  that hears it, depending on the attack and whether management-frame protection is in play (Module 12).
- **Interception leaks.** Monitor mode captures *everything* on a channel, not just your traffic.
  Capturing your neighbour's frames, even passively, can be unlawful interception.
- **Rogue infrastructure leaks.** A rogue AP or evil twin advertises to every client in range; a
  stranger's device may try to associate (Module 9).

### Containment controls (use all of them)

1. **Target allowlist.** Write down the exact BSSIDs/SSIDs you own and are testing. Everything else is
   out of scope and must not be probed, deauthed, or captured. Use the
   [scope & authorisation template](../../templates/authorisation-template.md).
2. **Controlled test clients.** Use devices you own and can configure as the only clients in your
   exercises, so an attack's effect is confined to them.
3. **Minimum necessary transmission.** Lowest TX power that works, a specific channel, and a
   directional or attenuated antenna where possible. More power buys you nothing in a lab and spills
   further.
4. **Prefer virtual or shielded setups for transmit-heavy work.** The virtual (`mac80211_hwsim`) path
   transmits nothing over the air — use it for anything you don't strictly need real RF for. An RF
   shield (test enclosure) is the physical equivalent.
5. **Stop conditions.** Stop immediately if any device not on your allowlist associates or is affected,
   if you see interference with a production/neighbour network, or at the end of your time window.
6. **Cleanup.** Stop services, remove rogue APs, restore clients and interfaces, delete synthetic
   credentials. `labs/common/reset-lab.sh` does this; make it a reflex.

### The law, framed honestly

This is general guidance, not legal advice, and the specifics vary by country — but the categories are
stable:

- **Authorisation.** Testing a network you are not authorised to test is illegal in essentially every
  jurisdiction (unauthorised access / computer-misuse laws). In this course, the only authorised
  targets are equipment **you personally own**.
- **Interception.** Capturing others' communications can violate wiretap/interception law even if you
  never decrypt them. Monitor mode is powerful and indiscriminate — keep it pointed at your own gear.
- **Interference.** Deliberately disrupting radio communications (jamming, deauth floods against others)
  is typically a separate offence and often strictly enforced.
- **Radio regulation.** TX power limits, which channels you may use, DFS requirements, and band
  licensing differ by country. Changing your regulatory domain to unlock power/channels you're not
  permitted to use can itself be unlawful. Check your jurisdiction before you transmit.

Every offensive page in this course repeats the distinction **LAB TARGET vs REAL NETWORK** and the
authorisation requirement, and opens risky steps with a warning. That repetition is deliberate.

## Hands-on

### Guided walkthrough — write your lab's ground rules

1. Copy the [scope & authorisation template](../../templates/authorisation-template.md) into your
   notes. Fill in the allowlist with the equipment you own (even if that's just "one AP, one laptop,
   one phone — all mine").
2. Write your **transmission limits** (channel, lowest TX power) and **stop conditions**.
3. Note your **regulatory domain** and where you'll confirm local rules. You'll set it in Module 3
   with `iw reg`.
4. Bookmark `labs/common/reset-lab.sh` as your end-of-session cleanup.

> [!NOTE]
> **Lab paths:** R (writing your ground rules — no hardware). **Start state:** no lab built yet.
> **Duration:** ~10 min. **Artifacts:** a completed scope/authorisation sheet for your own lab.
> **Cleanup:** none. This document is reused by every later lab and both capstones.

## Exercise

A learner says: "My lab is on its own isolated VLAN with no Internet access, so I can run a deauth
flood as hard as I like — nothing can escape." Identify what's wrong with this reasoning and list the
containment controls that *actually* limit the blast radius here.

<details>
<summary>Hint</summary>

The VLAN contains layer-2/3 traffic on the wire; it does nothing about the radio. Deauth frames are
transmitted over the air and affect any device in range on that channel. The controls that matter are
minimum TX power, a controlled client, a specific channel, stop conditions, and preferring the virtual
path or an RF shield — not network isolation.
</details>

<details>
<summary>Reference answer</summary>

"Isolated VLAN, no Internet" addresses the wire, not the air. A deauth flood is radiated RF; it can
disrupt the learner's neighbours and any device in range on that channel, regardless of what the wired
side looks like. Real containment: allowlist the target, use one controlled client, transmit at minimum
power on a chosen channel, set stop conditions, and prefer `mac80211_hwsim` (which never transmits) or
an RF shield for this kind of transmit-heavy test. The VLAN is irrelevant to the actual risk.
</details>

## References

- IEEE 802.11-2020 — frame types that propagate over the air (`references/README.md`).
- [Scope & authorisation template](../../templates/authorisation-template.md).
- `PUBLISHING_WARNING.md` (repo root) — what to review before making any of this public.

## What you should now be able to do

- Explain why network isolation does not contain radio, and name the real leakage paths.
- Apply the containment controls — allowlist, controlled client, minimum transmission, stop
  conditions, cleanup — to your own lab.
- Frame wireless testing legally around authorisation, interception, interference, and local radio law.
