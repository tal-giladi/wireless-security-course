---
id: "14.1"
module: 14
minutes: 25
practice_minutes: 30
prerequisites: ["02.3"]
objectives:
  - Assemble the course's defence controls into a single ongoing wireless-security program rather than a one-off checklist.
  - Map each control — segmentation, AP hygiene, firmware, WPS, client policy, monitoring, WPA3/PMF baseline — to where it was introduced and how it is maintained over time.
  - Produce a defence-program document for an owned-lab environment that assigns an owner, a cadence, and a verification method to every control.
volatility: concept
sources:
  - title: "NIST SP 800-153 — Guidelines for Securing Wireless Local Area Networks (WLANs)"
    url: https://csrc.nist.gov/pubs/sp/800/153/final
  - title: "CIS Critical Security Controls v8 (asset management, secure configuration, continuous monitoring)"
    url: https://www.cisecurity.org/controls
  - title: "Wi-Fi Alliance — security (WPA3, PMF, configuration guidance)"
    url: https://www.wi-fi.org/discover-wi-fi/security
last_verified: "2026-10-01"
---

# 14.1 · The defence program

The secure baseline you set in Module 2 and revisited in every attack module is not a configuration you apply once; it is a program you run continuously. This lesson pulls the whole defence thread of the course together — segmentation, AP administration hygiene, firmware maintenance, WPS configuration, client policy, monitoring and rogue detection, and the WPA3/PMF protocol baseline — and turns it into an ongoing program with owners, a cadence, and a way to prove each control still works.

## Why this matters

A penetration test is a snapshot; an attacker gets every day after it. A network that was hardened on the day of the engagement drifts: firmware ages into known CVEs, a new access point appears without segmentation, a managed client profile is loosened for a support call and never restored, WPS gets re-enabled for a printer. Every attack in this course had a hardened counterpart, but the hardened configuration only protects the network for as long as someone keeps it hardened. Framing defence as a program — not a checklist you tick once — is what makes the difference between a network that passed a test and a network that stays defensible. It is also what you are really recommending when you write the remediation section of a report (Lesson 14.2): not "fix this finding," but "run this control."

## Learning objectives

- Assemble the course's defence controls into a single ongoing wireless-security program rather than a one-off checklist.
- Map each control to where it was introduced in the course and describe how it is maintained over time.
- Produce a defence-program document for an owned-lab environment that assigns an owner, a cadence, and a verification method to every control.

## Prerequisites

- Lesson 02.3 — the secure wireless baseline. This lesson assumes you have the baseline checklist (segmentation, AP hygiene, firmware, WPS, client policy, monitoring) and the vulnerable-vs-hardened measurements that go with each control.

## Concept

This is a defence lesson, so each part is a control or process, followed by how you keep it true over time. **LAB TARGET vs REAL NETWORK:** you build and run this program against equipment you own; running it against an organisation's network needs authorisation and an agreed scope.

### The control or process

The baseline in Lesson 02.3 named six control areas plus the protocol choice underneath them. A program adds three things to each: an **owner** (who is responsible), a **cadence** (how often it is checked or renewed), and a **verification method** (the evidence that proves it is still in force — usually the same vulnerable-vs-hardened measurement the attack module used).

**1. Segmentation (guest vs internal) — introduced in Module 2.3.** Guests and untrusted devices stay on their own VLAN/SSID with client isolation and firewall rules to internal resources. As a program: re-verify after any network change, and whenever a new SSID or AP is added. *Verification:* from a guest client, attempt to reach an internal host — it must still be blocked.

**2. AP administration hygiene — Module 2.3.** Default admin credentials changed, remote/WAN management off, unused services disabled, management over HTTPS/SSH on a management VLAN, and a current inventory of every AP and its configuration. As a program: the inventory is the anchor — you cannot defend APs you do not know you have. *Verification:* the inventory matches what monitoring actually sees on the air (control 6).

**3. Firmware maintenance — Module 2.3, with the consequences in Module 12.** Track firmware versions, subscribe to vendor advisories, patch on a schedule. This is how KRACK, FragAttacks, and Kr00k (Module 12) are fixed in practice — not by a clever configuration but by applying the vendor's fix. As a program: an advisory-to-patch workflow (Lesson 12.4 turned a CVE into a check; the program turns the check into a patch). *Verification:* current versions compared against the latest advisories; no known-applicable CVE left unpatched.

**4. WPS configuration — Module 2.3, attacked in Module 8.** Baseline is WPS disabled, or at most time-boxed push-button, never the external PIN method. As a program: re-check after firmware updates and factory resets, which often re-enable it. *Verification:* `wash`-style scan shows no WPS, or push-button only (Lesson 8.4).

**5. Client policy — Module 2.3, exploited in Modules 9 and 11.** Server-certificate validation on Enterprise clients (Module 11.5), MAC randomisation on, auto-join and preferred-network-list hygiene (Module 9). As a program: enforce through managed profiles (MDM/Group Policy) so a user cannot quietly disable server validation, and review the fleet's settings on a cadence. *Verification:* a rogue RADIUS is refused by the fleet (Module 11.5); an evil twin for a pruned SSID attracts nothing (Module 9).

**6. Monitoring and rogue detection — Module 2.3, built out in Module 9.5.** Know your legitimate BSSIDs/SSIDs and watch for rogue APs, evil twins, and deauth floods. As a program: monitoring is what makes the whole thing *ongoing* rather than point-in-time — it is the control that detects the drift in all the others. *Verification:* a planted test rogue AP (owned, synthetic SSID) is detected and alerted within the expected window.

**The protocol baseline underneath — Modules 6, 7.** WPA3-SAE with PMF required where clients allow it; a high-entropy passphrase on any PSK network (Module 6.5); CCMP-only, no TKIP; OWE rather than bare Open for public access; transition mode treated as only as strong as its WPA2 side and scheduled for retirement. *Verification:* the measurements from those modules — no offline-crackable material on SAE-only (Module 7.1), forged deauth rejected with PMF (Modules 6.5, 7, 12.1), a bounded crack that fails against the strong passphrase (Module 6.4).

### From checklist to program — and how to measure it

A program is the baseline checklist plus governance. The table below is the shape of the program document you will produce in the lab: every control carries where it came from, who owns it, how often it is checked, and the evidence that proves it still holds.

| Control area | Introduced | Cadence | Verification (evidence the control still works) |
|---|---|---|---|
| Segmentation | M2.3 | On every network change | Guest-to-internal reach attempt is blocked |
| AP admin hygiene | M2.3 | Quarterly + on change | Inventory matches monitoring; no default creds / WAN mgmt |
| Firmware maintenance | M2.3, M12 | Monthly advisory review | Versions current; no applicable unpatched CVE |
| WPS configuration | M2.3, M8 | After each firmware update/reset | Scan shows WPS off or push-button only |
| Client policy | M2.3, M9, M11 | Quarterly fleet review | Rogue RADIUS refused; pruned SSID not auto-joined |
| Monitoring / rogue detection | M2.3, M9.5 | Continuous | Planted test rogue AP detected and alerted |
| Protocol baseline (WPA3/PMF/PSK) | M6, M7 | On deployment + review | SAE-only no offline hash; deauth rejected under PMF |

The point of the program is that each row is a living commitment with evidence, not a line that was true once. When you later write the remediation and residual-risk sections of a report, you are recommending exactly these rows — and the residual risk is whatever the program does not yet cover.

## Hands-on

### Guided walkthrough — turn the baseline checklist into a program document

A paper/analysis exercise, R path, no radio. Using your completed baseline checklist from Lesson 02.3 and the program skeleton in `../../labs/module-14/`:

1. Open `defence-program-skeleton.md` from the module zip. It lists the seven control areas above with empty **owner**, **cadence**, and **verification** columns.
2. For each control, carry over your Lesson 02.3 vulnerable-vs-hardened measurement into the **verification** column — this is how you will prove the control still works, not just that it was once set.
3. Assign an **owner** and a **cadence** to each row. For a home/owned lab the owner may be "me," but write it down; the discipline is that every control has someone and a schedule.
4. Add a short **drift log** section: three events that would require re-verifying a control out of cadence (e.g. "firmware update," "new AP added," "support call that touched a client profile").
5. Save the completed program. It is the document a decision-maker would adopt and the thing your report's remediation section ultimately points to.

> [!NOTE]
> **Lab paths:** R — produce a defence-program document from a supplied skeleton and your Lesson 02.3 checklist; no hardware. It proves you can assemble the course's controls into an ongoing, owned, verifiable program. It does **not** prove you have deployed or continuously operated these controls on live equipment — that is operational work beyond the course.
> **Start state:** `defence-program-skeleton.md` from the module zip and your completed `baseline-checklist.md` from Lesson 02.3.
> **Duration:** ~30 min.
> **Artifacts:** a completed defence-program document — seven controls, each with owner, cadence, and a verification method tied to a vulnerable-vs-hardened measurement, plus a short drift log.
> **Cleanup:** none (paper exercise). If you later apply any control to an AP you own, record before/after configuration as evidence.

## Exercise

A 20-person company passed a wireless penetration test eight months ago: at the time, WPA3-SAE with PMF was configured, guests were segmented, and firmware was current. Today the company says "we fixed everything the testers found, so we are covered." Without running any attack, identify three realistic ways the network could have drifted back into a vulnerable state since the test, and for each name the control that would have caught it and the verification evidence that proves it.

<details>
<summary>Hint</summary>

Think about which controls change silently over time rather than being attacked. Firmware ages. New APs and SSIDs appear. Client profiles get loosened for support and not restored. WPS comes back after a factory reset. Each of those maps to a control row and its cadence/verification in the program table — and each is a reason a snapshot test is not the same as a running program.
</details>

<details>
<summary>Reference answer</summary>

A defensible three (others are reasonable — the reasoning and the evidence matter):

1. **Firmware aged into a new CVE.** A snapshot in time cannot cover advisories published since. The firmware-maintenance control (monthly advisory review) catches it; verification is current versions compared against the latest advisories with no applicable unpatched CVE (the Module 12.4 check, now run on a cadence).
2. **A new access point or SSID was added without segmentation or the protocol baseline.** The AP-admin-hygiene and monitoring controls catch it: the inventory no longer matches what monitoring sees on the air, and a guest-to-internal reach test from the new SSID shows whether segmentation was applied.
3. **A client profile was loosened and not restored** (e.g. server-certificate validation disabled for a support call). The client-policy control catches it on the quarterly fleet review; verification is that a rogue RADIUS is still refused by the fleet (Module 11.5) — a client that now accepts it has drifted.

The lesson: "we fixed the findings" addresses a snapshot; "we run the program" addresses the eight months since. Every one of these is a control with an owner, a cadence, and a measurement — which is exactly what distinguishes a defence program from a one-off remediation.
</details>

## References

- NIST SP 800-153 — securing wireless LANs (program-level WLAN security guidance) (`../../references/README.md`).
- CIS Critical Security Controls v8 — asset inventory, secure configuration, continuous monitoring as ongoing controls (`../../references/README.md`).
- Wi-Fi Alliance — WPA3/PMF configuration guidance (`../../references/README.md`).
- The baseline this program ties together: `../module-02/lesson-03.md`.
- Where each control was exercised: firmware/CVE `../module-12/lesson-04.md`; rogue detection `../module-09/lesson-05.md`; client validation `../module-11/lesson-05.md`.
- Glossary: secure baseline, segmentation, PMF, WPS, managed client profile, rogue AP, WIDS (`../../glossary.md`).

## What you should now be able to do

- Assemble the course's defence controls into a single ongoing program rather than a one-off checklist.
- Map each control to where it was introduced and state how it is maintained — owner, cadence, verification.
- Produce a defence-program document for an owned-lab environment with a verification method tied to a vulnerable-vs-hardened measurement for every control.
