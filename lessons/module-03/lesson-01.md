---
id: "03.1"
module: 3
minutes: 18
practice_minutes: 10
prerequisites: ["00.1"]
objectives:
  - Choose the recorded, virtual, or physical lab path by the goal of each exercise.
  - State honestly what each path proves and what it cannot prove, per the lab matrix and rubrics.
  - Plan a route through the course that needs zero purchases, treating the physical path as optional.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (the protocols the labs exercise)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Linux mac80211_hwsim simulated-radio documentation"
    url: https://www.kernel.org/doc/html/latest/networking/mac80211_hwsim/mac80211_hwsim.html
last_verified: "2026-10-01"
---

# 03.1 · Choosing your path — recorded, virtual, or physical

Before you install a single tool or buy any hardware, decide which of the three lab paths each exercise deserves, because the paths prove genuinely different things and the course credits them separately. This lesson gives you an honest decision rule: when recorded-data analysis is enough, when a virtual radio reproduces the protocol flow you need, and when only a physical rig will do — and it shows that the whole course is completable on the recorded and virtual paths with nothing to buy, so the physical path is an upgrade you choose, never a gate you are stuck behind.

## Why this matters

The fastest way to waste money and time in wireless security is to buy an adapter you did not need, or to conclude you cannot learn the material because you lack hardware. Neither is true. Most of what makes someone good at this work — reading a handshake, reasoning about when an attack applies, configuring an AP and a supplicant correctly, telling a real downgrade surface from a myth — needs no radio at all. Picking the right path per exercise lets you move quickly now and spend on hardware later, only when an exercise genuinely requires real RF. Getting this honest with yourself early also keeps your later claims honest: a report that says "verified by capture" when you only read a supplied file is a credibility problem you avoid by knowing exactly what you did.

## Learning objectives

- Choose **R**, **V**, or **P** for an exercise from its goal, not from what hardware you happen to own.
- State, for each path, **what it proves and what it does not** — and why R and V never grant physical credit.
- Plan a **zero-purchase route** through the course, adding the physical path only where it adds something.

## Prerequisites

- [00.1 · What you'll learn, the three lab paths, and expectations](../module-00/lesson-01.md) — this lesson turns that overview into a working decision rule.

## Concept

### The three paths, and the one question that separates them

Every lab in this course is tagged with the paths it supports. The paths are defined in full in [`../../curriculum/lab-matrix.md`](../../curriculum/lab-matrix.md) and their completion criteria in [`../../curriculum/assessment-rubrics.md`](../../curriculum/assessment-rubrics.md); here is the decision view.

| Path | What you use | Proves | Does **not** prove | Cost |
|---|---|---|---|---|
| **R** Recorded-data | supplied `.pcapng`/`.hc22000` files + analysis tools | frame/handshake/EAP interpretation, the cracking workflow, reasoning about when an attack applies | live capture, injection, real RF behaviour | none |
| **V** Virtual (`mac80211_hwsim`) | a Linux VM with simulated radios, `hostapd`, `wpa_supplicant` | protocol flows end to end, AP/supplicant/RADIUS configuration, many attack *mechanics* | real RF, real drivers, range, interference, regulatory behaviour, hardware monitor/injection quirks | none |
| **P** Physical | an owned adapter, an owned AP, a controlled client | real monitor mode, injection, capture, range, interference handling | — (this is the ground truth) | hardware |

The single question that separates them: **does this exercise depend on real radio, or only on the protocol and the reasoning?** If you only need to understand or interpret, R is enough. If you need to run the protocol or an attack's *logic* end to end, V reproduces it without a radio. Only if the exercise is *about* the radio — capturing live frames off the air, injecting a frame, measuring range or interference — do you need P.

### Why the paths are credited separately (and honestly)

Wireless is physical, so the course refuses to pretend that reading a file is the same as pulling a handshake out of the air. A recorded-data learner who cracks a supplied capture has proven the *cracking workflow*, not that they can capture a handshake with an antenna. A virtual-path learner who stands up `hostapd` and watches a client associate has proven they understand *association*, not that their driver does monitor mode. This is not bureaucratic — it is the same honesty your eventual engagement reports need. The rubric records **which path you actually used**, and **R and V never grant P ("physical RF") credit**. You lose nothing by being precise; you gain a defensible account of what you did.

### The course is completable with zero purchases

Read this plainly: **you can finish the core course on R + V alone.** Analysis modules (recon, capture, cracking workflow) run on supplied captures (R). Protocol and configuration modules (joining, WPA2/WPA3 handshakes, enterprise RADIUS, rogue-AP mechanics) run on `mac80211_hwsim` (V). The physical path is where you later *confirm* on real hardware what you already understand — real monitor/injection, range, interference — and it is **optional by design** ([`TOOLS.md`](../../TOOLS.md) says so too). If you are deciding whether to buy an adapter today, the answer is: not yet. Learn on R + V, and buy only when you reach an exercise whose whole point is real RF and you want that credit.

### A worked decision rule

- "I want to understand the 4-way handshake and practise cracking a captured one." → **R.** You are interpreting and running a workflow; no radio needed.
- "I want to see a client discover, authenticate, and associate, and configure the AP myself." → **V.** The protocol flow is exactly what `hwsim` reproduces.
- "I want to prove my adapter can actually capture a handshake off the air and that injection works." → **P.** That claim is about real radio, so only P earns it.
- "I want to study WPA3 transition-mode downgrade logic." → **V** for the mechanics (and R for supplied captures); **P** only if you specifically need real-client, real-RF behaviour.

When a lab offers more than one path, pick the lowest one that meets your goal, and record it.

## Hands-on

This lesson's work is planning, not capture — path **R** in the sense that it needs no hardware and transmits nothing. You produce a written path plan you will reuse for the rest of the course.

### Guided walkthrough — build your path plan

1. Open [`../../curriculum/course-outline.md`](../../curriculum/course-outline.md) and skim the **Paths** column for each module (R / V / P).
2. For each module you intend to take, write the **lowest path that meets your goal** for that module. For analysis-only modules that is R; for protocol/config modules that is V.
3. Mark every exercise you are tempted to do on P, and next to it write the **one thing** P proves there that V/R cannot (e.g. "real injection", "live off-air capture", "range"). If you cannot name that thing, keep it on V.
4. Note your **budget**: with R + V only, your hardware cost is zero. Decide, honestly, whether any P item is worth a purchase *now* or can wait until you reach it.

### Lab — record what each path will and will not prove

> [!NOTE]
> **Lab paths:** R (planning only — no hardware, nothing transmitted; proves you can choose a path and state its limits, not that you performed any capture).
> **Start state:** no lab built yet; you have read [00.1](../module-00/lesson-01.md) and skimmed the lab matrix and rubrics.
> **Duration:** ~10 min.
> **Artifacts:** a one-page path plan listing, per module, the chosen path and — for any P item — the specific capability P proves that R/V cannot.
> **Troubleshooting:** if you cannot decide a path, ask "does this depend on real radio or only the protocol/reasoning?"; if "only protocol/reasoning", it is V or R. If you wrote P everywhere, re-check — most modules do not need it.
> **Cleanup:** none; keep the plan, you will reuse it in every lab module and both capstones.

## Exercise

A learner writes in their notes: "I cracked the WPA2 handshake in the module zip, so I can put 'performed a wireless handshake capture and crack' on my résumé." Explain precisely what they have and have not demonstrated, which path they were actually on, and what they would need to do to legitimately claim the capture.

<details>
<summary>Hint</summary>

Separate the two skills bundled in that sentence: *interpreting / cracking a handshake* versus *capturing one off the air*. Which path supplies the file, and what does the rubric say R and V can and cannot be credited as?
</details>

<details>
<summary>Reference answer</summary>

They cracked a **supplied** capture, so they were on path **R**. That legitimately proves the **cracking workflow and their ability to interpret a handshake** — a real skill. It does **not** prove they captured anything off the air: the file was given to them, no radio was involved, and the rubric is explicit that **R (and V) never grant physical-capture or injection credit**. An honest claim is "analysed and cracked a supplied WPA2 handshake." To claim the capture itself they would have to do it on path **P** — a real adapter in monitor mode pulling a genuine 4-way handshake from *their own* AP and client off the air — and record that artifact. The distinction is exactly the kind of honesty an engagement report requires.
</details>

## References

- [`../../curriculum/lab-matrix.md`](../../curriculum/lab-matrix.md) — the three paths, adapters, and per-capability columns.
- [`../../curriculum/assessment-rubrics.md`](../../curriculum/assessment-rubrics.md) — per-path completion criteria; why R/V are not credited as P.
- [`../../curriculum/course-outline.md`](../../curriculum/course-outline.md) — the Paths column per module.
- [`../../TOOLS.md`](../../TOOLS.md) — tool inventory; the physical path is optional.

## What you should now be able to do

- Choose R, V, or P for any exercise from its goal, defaulting to the lowest path that meets it.
- State, for each path, what it proves and what it cannot — and why R and V are never credited as physical.
- Plan a zero-purchase route through the course and justify any physical-path item by the specific capability it proves.
