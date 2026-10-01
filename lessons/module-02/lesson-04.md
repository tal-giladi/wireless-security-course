---
id: "02.4"
module: 2
minutes: 15
practice_minutes: 0
prerequisites: ["02.1"]
objectives:
  - Explain in one paragraph each what WEP, TKIP, and RC4 were and why they are deprecated.
  - Recognise a deprecated cipher advertised in a capture and know to flag it as a finding, not a lab.
  - State the WEP hands-on gap this course does not cover and where to practise it for OSWP.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (deprecation of WEP and TKIP)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wi-Fi Alliance — security (WPA2/WPA3 supersede WEP/TKIP)"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "OffSec PEN-210 (OSWP) syllabus — encryption history and exam scope"
    url: https://www.offsec.com/courses/pen-210/
last_verified: "2026-10-01"
---

# 02.4 · Legacy and deprecated — WEP, TKIP, and RC4

WEP, TKIP, and the RC4 cipher under them are part of Wi-Fi's history, not its present, and this course treats them as exactly that: a short note so you recognise them in the field, plus an honest statement of the one certification gap this choice creates. There is no lab here and no attack walkthrough — the modern-first rule means we spend our hands-on budget on WPA2, WPA3, and Enterprise, and point you to external resources if you specifically need WEP practice for OSWP.

## Why this matters

You will still meet these on real networks — an old printer stuck on WEP, a consumer AP defaulting to "WPA/WPA2 mixed" with TKIP enabled, a legacy IoT device that speaks nothing newer. You need to recognise them, explain in a sentence why they are findings in their own right, and recommend the fix, without being lured into building a lab around a broken cipher. You also need to know, plainly, that because we do not lab WEP, a learner targeting the OSWP exam has a gap to close elsewhere. Badge for this lesson: **D — Deprecated (link-only).**

## Learning objectives

- Explain, in one paragraph each, what WEP, TKIP, and RC4 were and the core reason each is deprecated.
- Recognise a deprecated cipher advertised in a capture and treat its presence as a finding to remediate, not a lab to run.
- State the WEP hands-on gap this course deliberately leaves and where to practise it separately for OSWP.

## Prerequisites

- Lesson 02.1 — the protocol family. You should already know what a modern RSNE advertises, which is what makes a legacy cipher stand out.

## Concept

### WEP — Wired Equivalent Privacy (badge D)

WEP was the original 802.11 confidentiality mechanism. It uses the RC4 stream cipher with a 24-bit initialisation vector (IV) prepended to a static shared key. The IV is far too short, so it repeats on a busy network, and RC4 keystream reuse plus weak-IV and known-plaintext weaknesses let an attacker recover the key from enough captured traffic — in minutes with modern tools, regardless of key length. WEP has been deprecated for well over a decade and formally removed as an acceptable security mechanism in the modern standard. Treat any WEP network as effectively unprotected; the remediation is to replace it with WPA2-PSK at minimum, preferably WPA3-SAE.

### TKIP — Temporal Key Integrity Protocol (badge D)

TKIP was the stopgap in the original WPA, designed to run on WEP-era hardware by wrapping RC4 with per-packet key mixing, a sequence counter against replay, and the Michael integrity check. It fixed WEP's worst key-recovery flaw but inherited RC4 and Michael's weaknesses, and attacks (e.g. Beck-Tews and successors) showed it was not durable. It is superseded by CCMP (AES). A network still advertising TKIP — often as part of a "WPA/WPA2 mixed" setting — should be moved to CCMP-only; leaving TKIP enabled also caps the network at legacy data rates on many devices.

### RC4 — the stream cipher underneath (badge D)

RC4 is the stream cipher that both WEP and TKIP relied on. It is fast and simple, which is why early protocols chose it, but it has well-documented keystream biases that undermine it across many uses (not only Wi-Fi — it was also removed from TLS). Modern Wi-Fi uses AES in CCMP (and GCMP for the newest modes) instead. When you see RC4 anywhere in a wireless context, it is a signal you are looking at WEP or TKIP and therefore at a deprecated configuration.

### Why we do not lab these — and the OSWP gap

The course's modernity rule is deliberate: WEP, TKIP, WPS online brute force, and RC4/DES-era crypto get a one-paragraph note and a link, never a lab, because hands-on time is better spent on what you will actually attack and defend today. This creates one disclosed **certification-preparation gap**: OSWP (PEN-210) still touches encryption history, and the exam environment can be legacy-flavoured, so a learner targeting OSWP must **practise WEP separately** — set up a WEP network on owned equipment and work through key recovery with the Aircrack-ng suite using an external guide. We flag this openly in `../../curriculum/course-outline.md`; it is a decision, not an oversight.

## Hands-on

There is **no lab and no attack walkthrough for this lesson** — by design (see the modernity rule above). The only practical skill here is *recognition*, which takes a moment on a capture you already have.

### Guided walkthrough — recognising a deprecated cipher

1. In the `baseline-beacons.pcapng` capture from Lesson 02.1 (`../../labs/module-02/`), look for any network whose RSN or legacy WPA information element lists **TKIP** as a group or pairwise cipher, or a network protected by **WEP** (which appears as privacy-enabled with no RSNE/CCMP). The supplied capture includes one deprecated-cipher example for practice.
2. Note how it differs from the CCMP/AES networks around it, and write a one-line finding: "SSID *X* advertises TKIP — deprecated; recommend CCMP-only (WPA2) or WPA3-SAE."

> [!NOTE]
> **Lab paths:** none. This lesson ships **no** lab exercise and **no** WEP/TKIP attack — only the recognition step above, on the capture already supplied for Lesson 02.1. Practising WEP key recovery for OSWP is an **external, owned-equipment** exercise this course does not provide.

## Exercise

A client site has an old label printer that only supports WEP and a guest AP set to "WPA/WPA2 mixed mode" with TKIP still enabled. The site owner says "it's all encrypted, so it's fine." Write the two-line findings you would record for each, and the remediation you would recommend — without proposing that you build a WEP-cracking lab as part of the engagement.

<details>
<summary>Hint</summary>

Each deprecated cipher is a finding on its own merits — you do not need to crack it to report it. For the printer, think about what "WEP" means for its traffic and whether it can be isolated if it cannot be upgraded. For the mixed-mode AP, the problem is that the weak option is still on the menu.
</details>

<details>
<summary>Reference answer</summary>

**WEP printer.** Finding: the device uses WEP, which is deprecated and effectively unprotected — its traffic can be decrypted and its key recovered from captured traffic. Remediation: replace or upgrade the device if possible; if it genuinely cannot be upgraded, isolate it on its own segment with strict firewall rules and treat its link as untrusted. You do not need to crack it to justify the finding.

**Mixed-mode / TKIP guest AP.** Finding: the AP still offers TKIP (RC4-based, deprecated), so even clients capable of CCMP may negotiate the weaker cipher and the network is capped at legacy behaviour. Remediation: set the AP to CCMP (AES) only, disable TKIP, and move toward WPA3-SAE where supported. The key point: "it's encrypted" is not the bar — a deprecated cipher is a reportable weakness regardless of whether you demonstrate an attack, and the fix is a configuration change, not a lab.
</details>

## References

- IEEE 802.11-2020 — deprecation of WEP and TKIP in favour of CCMP (`../../references/README.md`).
- Wi-Fi Alliance — security: WPA2/WPA3 supersede WEP/TKIP (`../../references/README.md`).
- OffSec PEN-210 (OSWP) — encryption history and the disclosed WEP gap (`../../references/README.md`).
- OSWP gap disclosure and coverage matrix: `../../curriculum/course-outline.md` (planning doc).
- Glossary: WEP, TKIP (`../../glossary.md`).

## What you should now be able to do

- Explain in one paragraph each what WEP, TKIP, and RC4 were and why each is deprecated.
- Recognise a deprecated cipher in a capture and record it as a finding with a remediation, without building a lab around it.
- State the WEP hands-on gap this course leaves for OSWP candidates and where to close it.
