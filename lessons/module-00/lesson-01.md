---
id: "00.1"
module: 0
minutes: 15
practice_minutes: 10
prerequisites: []
objectives:
  - Describe the course's core path and electives and the rough study/practice time each needs.
  - Choose a lab path (recorded-data, virtual, or physical) and state what it can and cannot prove.
  - Explain honestly what this course does and does not claim about OSWP readiness.
volatility: concept
sources:
  - title: "OffSec PEN-210 (OSWP) course page"
    url: https://www.offsec.com/courses/pen-210/
last_verified: "2026-10-01"
---

# 00.1 · What you'll learn, the three lab paths, and expectations

This course takes you from how a radio carries a Wi-Fi frame all the way to running and reporting a
professional wireless assessment — learning every attack next to the defence that stops it. Before any
of that, this lesson sets honest expectations: what the course covers, how much time it takes, which of
the three lab paths you'll use, and what finishing it does and does not make you ready for.

## Why this matters

Wireless security is physical in a way that web or host security is not. A tutorial that says "run this
tool, get the key" hides the two things that actually make you competent: understanding *why* a
technique works and under which conditions it fails, and being honest about *what you actually did* —
analysing a supplied capture is not the same as pulling a handshake out of the air. Starting with clear
scope and honest expectations is what separates a skill you can stand behind from a party trick.

## Learning objectives

- Describe the course's **core path** and **electives**, and the rough study/practice time for each.
- Pick a **lab path** and state precisely what it proves and what it does not.
- Explain what the course claims about **OSWP** readiness — and the gaps it openly discloses.

## Prerequisites

None beyond the course's entry requirements (Linux shell comfort and TCP/IP basics). The next lesson,
[Readiness self-check](lesson-02.md), helps you confirm you have them and points to a prep path if not.

## Concept

### The shape of the course

The course is a **core path** everyone should take, plus **electives** you can skip or come back to.

- **Core:** foundations (RF and 802.11), the security protocols and a secure baseline, building a lab,
  reconnaissance, capture and analysis, WPA2-Personal (handshake/PMKID/cracking **and** hardening),
  WPA3-SAE, rogue AP / evil twin / client-side, Enterprise across two modules
  (build → attack → harden → retest), engagements and methodology, and a defence-and-reporting track.
- **Electives:** WPS; modern protections and the famous attacks as context (PMF, KRACK, FragAttacks,
  Kr00k); and an awareness tour of adjacent wireless (BLE, Zigbee, RFID, SDR).

Rough budget for the core path: **~45–60 h of study + ~30–45 h of practice**; electives add ~15–20 h.
Each module page restates its own time and any cost. These are estimates and will be refined.

### The three lab paths — and what each honestly proves

Wireless is physical, so we are strict about what counts as having *done* something. You pick a path per
lab (and many labs support more than one):

| Path | Hardware | Proves | Does **not** prove |
|---|---|---|---|
| **R** Recorded-data | none | reading frames/handshakes/EAP, the cracking workflow, reasoning | live capture, injection, RF behaviour |
| **V** Virtual (`mac80211_hwsim`) | none (a Linux VM) | protocol flows, AP/supplicant/RADIUS config, many attack mechanics end-to-end | real RF, real drivers, range, interference, hardware monitor/injection quirks |
| **P** Physical | real adapters + AP + client | real monitor mode, injection, capture, range, interference | — |

The whole course is completable on **R + V with zero purchases**. The physical path is optional and is
the only one that proves real RF skills — so a recorded-data learner is **never** credited with having
performed physical capture or injection. Every lab says which paths it supports and what each proves.

### What this course claims — and what it does not

This course is aligned with most objectives of OffSec's **PEN-210 / OSWP** and modernises them (WPA3,
PMKID, hashcat `-m 22000`, 802.1X/EAP, management-frame protection). It does **not** promise that
finishing it passes the exam or prepares you for every professional engagement. It openly discloses its
gaps — most notably **no WEP hands-on** (WEP is a short legacy note) and **deep bettercap tool-drills**
being optional. The full objective-by-objective matrix with gaps is in
`curriculum/course-outline.md` (a planning document). You close those gaps deliberately, not by
pretending they aren't there.

## Hands-on

### Guided walkthrough — choose your path

1. Decide your realistic situation: Do you have (or want to buy) a monitor/injection-capable USB
   adapter and an AP you own? If yes, you can use the **physical** path. If not, you lose nothing
   important for most of the course on **recorded + virtual**.
2. Skim `curriculum/lab-matrix.md` (planning doc) if you're considering hardware — it teaches the
   **buy-by-chipset** rule. Do not buy anything yet; the lab-building module (Module 3) walks you
   through verification first.
3. Open the [lab notebook template](../../templates/lab-notebook-template.md). From the next lab
   onward you record, per entry, **which path you used** and what it proved.

> [!NOTE]
> **Lab paths:** R (reading this course and planning). **Start state:** a fresh course, no lab built
> yet. **Duration:** ~10 min. **Artifacts:** a one-line note in your lab notebook naming the path you
> intend to use for the course. **Cleanup:** none.

## Exercise

Write two or three sentences in your lab notebook answering: *Which path(s) will I use, and for each
claim I'll eventually make ("I captured a WPA2 handshake"), what evidence would honestly back it up?*
There is no single correct answer — the point is to tie a claim to the path that can prove it.

<details>
<summary>Hint</summary>

"I cracked a WPA2 handshake" is backed by a `.hc22000` file and the recovered passphrase **and** a note
of whether you captured it live (P), in the VM (V), or were given it (R). The claim you can defend
depends entirely on the path.
</details>

## References

- OffSec PEN-210 (OSWP) course page — the syllabus this course maps to (`references/README.md`).
- `curriculum/course-outline.md` — the full module map and OSWP coverage matrix with disclosed gaps.

## What you should now be able to do

- Name the core path and the electives and give a rough time budget for each.
- Choose a lab path and state, honestly, what it proves and what it doesn't.
- Explain what the course claims about OSWP readiness and where its disclosed gaps are.
