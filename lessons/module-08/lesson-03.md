---
id: "08.3"
module: 8
minutes: 12
practice_minutes: 0
prerequisites: ["08.1"]
objectives:
  - Summarise the original online WPS PIN brute force and why its 11,000-guess keyspace was once practical.
  - Explain why modern APs mostly mitigate it through WPS lockout and rate-limiting, making it slow and noisy.
  - Decide when the online brute is still worth noting as residual risk versus when Pixie Dust or disabling WPS is the real story.
volatility: implementation
sources:
  - title: "US-CERT/CISA VU#723755 — WiFi Protected Setup PIN brute force vulnerability and WPS lockout response"
    url: https://www.kb.cert.org/vuls/id/723755
  - title: "reaver-wps-fork-t6x README — rate-limiting, lock detection (-l), and online PIN brute behaviour"
    url: https://sources.debian.org/src/reaver/1.6.6-2/README.md
last_verified: "2026-10-01"
---

# 08.3 · Online PIN brute force — mostly-mitigated legacy

The original 2011 WPS attack was an online brute force: submit WPS PINs to the AP one after another until the split-half validation of 08.1 reveals the right one in at most 11,000 attempts. This short lesson is a legacy summary, not a lab — it exists so you understand the historical attack and can recognise its signs, while being clear that modern APs mostly defeat it with lockout and rate-limiting, which is why this course keeps a full lesson only for Pixie Dust (08.2) and spends its energy on remediation (08.4).

## Why this matters

The online PIN brute is where "Attacking WPS" began, and the OSWP/PEN-210 syllabus still references it, so you should be able to explain it. But treating it as a live go-to attack in 2026 would be misleading: the course's **modernity/deprecation rule** flags it as **mostly-mitigated legacy**, so you get the mechanism and the reasons it rarely pays off today — not a hands-on drill. Knowing *why* it was neutralised (lockout, rate-limiting) is also what lets you judge when an unlocked, un-rate-limited AP still presents residual risk worth a line in a report.

## Learning objectives

- Summarise the **original online PIN brute** and why its **11,000-guess** keyspace was once practical.
- Explain why modern APs **mostly mitigate** it via **WPS lockout** and **rate-limiting**, making it slow and noisy.
- Decide when the online brute is worth noting as **residual risk** versus when Pixie Dust or disabling WPS is the real story.

## Prerequisites

- [08.1 · How WPS works](lesson-01.md) — the split-half PIN validation is the entire basis of the online brute.

## Concept

### The legacy attack, in brief

Viehböck's 2011 result (08.1) made the online brute practical: because the AP validates the PIN in two independently-checkable halves, an attacker using a tool like **`reaver`** submits PIN guesses over the air and uses the AP's distinguishable responses to solve the **first 4 digits (≤10^4)** and then the **second half (≤10^3)** separately — **≤11,000** attempts instead of ten million. At one guess every 1–10 seconds, early vulnerable APs fell in roughly **4–10 hours** (often half that on average). No cryptography is broken; the AP is simply tricked into confirming the PIN a piece at a time, after which it hands over the WPA2 passphrase.

### Why modern APs mostly mitigate it

The attack's practicality depended on the AP answering unlimited guesses quickly. Vendors and the Wi-Fi Alliance responded:

- **WPS lockout.** After a few failed PINs the AP sets **AP Setup Locked** and refuses further WPS registration for a cooldown period — so the online loop stalls almost immediately. WPS 2.0 made lockout handling expected behaviour.
- **Rate-limiting / exponential back-off.** Many APs deliberately slow WPS responses after failures, stretching an 11,000-guess run from hours into days or indefinitely.
- **Honest caveat on the mitigation.** It is not uniform: some consumer APs implement lockout weakly (for example, lock for only 60 seconds, which `reaver`'s lock-detection `-l` can simply wait out), and a minority ship with WPS unlocked and no effective rate-limiting. So "mostly mitigated" means *common defaults have closed it*, not *it is impossible everywhere* — which is why an unlocked, un-rate-limited AP is still worth flagging.

Against this backdrop, **Pixie Dust (08.2) displaced the online brute** for testers: when an AP is vulnerable, one offline exchange beats hours of online guessing, and when it is not, hammering it online mostly just trips the lockout. There is therefore **no lab for the online brute in this course** — the practical WPS attack you run is Pixie Dust, and the practical defence is disabling WPS (08.4).

> [!CAUTION]
> Even as "legacy," an online PIN brute is an active, noisy, over-the-air attack that engages a registrar — it is only ever acceptable against an AP **you own**, on your allowlist, with synthetic credentials ([00.3](../module-00/lesson-03.md)). This lesson is summary-only; do not run it against anything you do not own.

## Hands-on

This lesson is a **legacy summary and has no lab** — by the course's deprecation rule the online PIN brute is not drilled hands-on. If you want to *see* the mitigation rather than the attack, do the two no-transmit observations below; the practical WPS attack lab lives in [08.2 (Pixie Dust)](lesson-02.md) and the practical defence in [08.4](lesson-04.md).

### Guided walkthrough — observe the mitigation, transmit nothing (path R)

1. In the supplied `wps-beacon.pcapng` from 08.1, re-read the WPS information element's **AP Setup Locked** field. An AP that sets this after failures is advertising its lockout state — the exact signal that neutralises an online brute.
2. On your **own** AP's admin page (if it exposes WPS settings), note whether it lists a **lockout** / failed-attempt threshold and any rate-limiting. Record it as configuration evidence for your 08.4 remediation write-up — no WPS frames are sent.

## Exercise

A penetration-test plan from 2012 says: "For every WPS-enabled AP, run `reaver` to brute-force the PIN; budget one working day per AP." You are updating this plan for a current engagement. Explain why this step is no longer a good default, what you would replace it with, and the one condition under which the online brute is still worth attempting.

<details>
<summary>Hint</summary>

Think about what a modern AP does after a handful of failed PINs, and how that interacts with a plan that assumes thousands of uninterrupted guesses. Then ask which WPS attack a tester actually reaches for first today, and what AP state would leave the slow online brute as the only remaining option.
</details>

<details>
<summary>Reference answer</summary>

The 2012 step assumes the AP will answer thousands of PIN guesses quickly, which modern defaults break: after a few failures most APs set **WPS lockout** and/or **rate-limit** responses, so a one-day `reaver` run usually stalls after minutes and recovers nothing while making a lot of noise. The better default is to **try Pixie Dust first** (`reaver -K` / `bully`): if the AP's chipset is vulnerable it yields the PIN and PSK offline in seconds, and if it is not, you have a clean "not vulnerable" finding without hammering the registrar. The **online brute is still worth attempting only** when an AP has WPS PIN enabled **and** is **unlocked with weak or no rate-limiting** (e.g. a device that locks for just 60 seconds, which `reaver -l` can wait out) **and** Pixie Dust has already failed — a narrow residual case. In almost every report the real recommendation is simply to **disable WPS** (08.4), which removes both the online and offline PIN attacks at once.
</details>

## References

- [US-CERT/CISA VU#723755 — WPS PIN brute force vulnerability](https://www.kb.cert.org/vuls/id/723755) — the original advisory and the lockout mitigation.
- [reaver-wps-fork-t6x README](https://sources.debian.org/src/reaver/1.6.6-2/README.md) — rate-limiting and lock-detection (`-l`) behaviour in the online brute.
- [08.2 · Pixie Dust](lesson-02.md) and [08.4 · Prevalence and remediation](lesson-04.md) — the attack that replaced the online brute, and the control that ends both.

## What you should now be able to do

- Summarise the original online WPS PIN brute and why the 11,000-guess split made it practical on early APs.
- Explain how WPS lockout and rate-limiting mostly mitigate it today, and where that mitigation is weak.
- Judge when an unlocked AP leaves residual online-brute risk versus when Pixie Dust or disabling WPS is the real finding.
