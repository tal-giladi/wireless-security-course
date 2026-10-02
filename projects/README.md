# Capstone projects

Two capstones let you prove the whole course end to end: a recorded-data capstone you can complete with no wireless hardware, and a physical-lab capstone against your own equipment. Both are assessed the same way, and on both the same rule holds — recovering a key is evidence inside a finding, never a pass on its own.

## The two capstones

- [Recorded-data capstone](recorded-data-capstone.md) — **path R**, no hardware. You are handed a realistic set of supplied captures for an authorised engagement, and you do the recon and interpretation, justify which techniques apply, assess the networks, and write a full report with remediation and residual risk. Proves frame/handshake/EAP interpretation and the cracking/analysis workflow and reasoning. Does **not** prove live capture, injection, or any RF behaviour.
- [Physical-lab capstone](physical-lab-capstone.md) — **path P** (use **path V**, virtual `mac80211_hwsim`, for any step where you lack the hardware). You build, attack, **harden, and retest** your own APs: WPA2 (handshake + PMKID), a WPA3 assessment, and an evil-twin against a lab client — then show each attack now fails. Proves real monitor/capture/injection/AP work against owned equipment. Steps run on V are credited as virtual, not physical.

A worked [sample report](sample-report.md) shows what a good write-up looks like, using synthetic findings for a fictional owned lab. Emulate its structure, not its specific numbers.

## How they are assessed

Both capstones are scored on the capstone rubric from [`../curriculum/assessment-rubrics.md`](../curriculum/assessment-rubrics.md), reproduced in each capstone page. The dimensions and weights are:

| Dimension | Weight |
|---|---|
| Recon & scoping | 15 |
| Interpretation / analysis | 20 |
| Justified technique selection | 15 |
| Evidence quality | 15 |
| Remediation | 15 |
| Retesting / verifying the fix | 10 |
| Report incl. executive summary, limitations, residual risk | 10 |
| **Total** | **100** |

Pass mark is **70**. The weighting is deliberate: interpretation, justification, evidence, remediation, and retest together outweigh anything to do with obtaining a key.

> [!IMPORTANT]
> **A recovered key alone is NOT a pass.** You can recover every passphrase in the set and still fail, if you cannot justify the technique, show the evidence, recommend a verifiable fix, and state the residual risk. You can also **pass without recovering any key** — correctly concluding a strong passphrase will not crack in scope (and recommending the control), or demonstrating that a protection works (PMF rejects the deauth, the hardened client rejects the rogue RADIUS), is a full result. This mirrors the lesson-level rule in [`../lessons/module-06/lesson-04.md`](../lessons/module-06/lesson-04.md) and the reporting discipline in [`../lessons/module-14/lesson-02.md`](../lessons/module-14/lesson-02.md).

## Per-path honesty (what each capstone can credit)

Wireless is physical, and the course is honest about what each path proves (plan §4; [`../curriculum/assessment-rubrics.md`](../curriculum/assessment-rubrics.md)).

| Path | Credited as | Proves | Does NOT prove |
|---|---|---|---|
| **R** recorded-data | analysis — recorded data | interpretation of supplied captures, cracking/analysis workflow, reasoning | live capture, injection, RF behaviour |
| **V** virtual (`mac80211_hwsim`) | protocol lab — virtual radios | protocol flows and attack mechanics end to end in a VM | real RF, drivers, range, interference, monitor/injection quirks |
| **P** physical | practical — physical RF | real monitor, capture, injection, AP work against owned equipment | — |

**R and V never grant physical-capture or injection credit.** The recorded-data capstone is a path-R result and is credited only as analysis. The physical capstone **records which path proved each claim** — if you ran the evil-twin step on virtual radios because you lacked a second adapter, that claim is credited as virtual, and your report says so. Never describe a virtual or recorded result as physical RF.

## Before you start either capstone

- Read [`../lessons/module-00/lesson-03.md`](../lessons/module-00/lesson-03.md) (safety, containment, and the law) and fill in [`../templates/authorisation-template.md`](../templates/authorisation-template.md). For these capstones the only legitimate owner of every target is **you**.
- Keep a [lab notebook](../templates/lab-notebook-template.md) — one entry per step, recording the path used and what it proved.
- Write the report against [`../templates/report-template.md`](../templates/report-template.md); study [the sample report](sample-report.md) first.
- All credentials are synthetic (`Lab-WiFi-Passw0rd!`, `LAB-FLAG-<uuid>`). Never use a real network, a real secret, or anyone else's equipment.
