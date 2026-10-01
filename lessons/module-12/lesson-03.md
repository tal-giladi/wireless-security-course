---
id: "12.3"
module: 12
minutes: 20
practice_minutes: 20
prerequisites: ["12.2"]
objectives:
  - Describe the FragAttacks aggregation, mixed-key, and fragment-cache classes as frame-handling flaws.
  - Explain Kr00k as an all-zero-key transmission of buffered frames after disassociation, scoped to specific chips.
  - Judge the current patched status of both and turn each into a version/chipset check on owned devices.
volatility: implementation
sources:
  - title: "Vanhoef — FragAttacks: Fragment and Forge (USENIX Security 2021)"
    url: https://www.fragattacks.com/
  - title: "ESET — Kr00k (CVE-2019-15126), all-zero-key vulnerability"
    url: https://www.welivesecurity.com/2020/02/26/kr00k-serious-vulnerability-affected-encryption-billion-wifi-devices/
  - title: "ESET — Kr00k technical overview (affected Broadcom/Cypress chips)"
    url: https://www.eset.com/int/kr00k/
last_verified: "2026-10-01"
---

# 12.3 · FragAttacks and Kr00k — fragment and clear-key classes

FragAttacks (Vanhoef, 2021) and Kr00k (ESET, 2020) are two more "famous" Wi-Fi vulnerability classes that are best understood as frame-handling and buffer-handling bugs with specific affected scope and shipped patches — not standing cryptographic breaks. FragAttacks is a set of design and implementation flaws in how 802.11 aggregates and fragments frames; Kr00k is a chipset bug that transmitted buffered frames under an all-zero key after a disassociation. This lesson explains both precisely and turns each into a chipset/version check you can run on owned equipment.

## Why this matters

These two round out the module's core habit: a scary 2020–2021 headline ("affects basically every Wi-Fi device") is a starting point for a per-device patch question, not a verdict. FragAttacks mattered because its design flaws touched every Wi-Fi protocol including WPA3, and because the implementation flaws were widespread; Kr00k mattered because it affected a billion-plus devices built on two common chip families. Both are now patched in current firmware and OS stacks — so the professional's job is to identify which owned devices carry the affected chipsets or pre-fix builds, not to assume either is a live universal break or, conversely, to dismiss a genuinely unpatched device.

## Learning objectives

- Describe the **FragAttacks** aggregation, mixed-key, and fragment-cache classes as **frame-handling flaws**, separating design from implementation bugs.
- Explain **Kr00k** as an **all-zero-key transmission of buffered frames after disassociation**, scoped to specific **Broadcom/Cypress** chips.
- Judge the **current patched status** of both and turn each into a **version/chipset check** on owned devices.

## Prerequisites

- [12.2 · KRACK — key reinstallation and what to verify now](lesson-02.md) — you need the "famous attack = patched class + per-device check" habit this lesson reuses and extends.

## Concept

### How FragAttacks worked

802.11 can **aggregate** several payloads into one frame (A-MSDU) and **fragment** one payload across several frames; both features existed long before anyone hardened their edge cases. Vanhoef's FragAttacks (2021) split into **design flaws** in the standard and **implementation flaws** in specific stacks.

- **Aggregation attack (CVE-2020-24588).** The A-MSDU "is this aggregated?" flag is not authenticated, so an attacker who can influence one field can make a receiver mis-parse a frame as aggregated, injecting attacker-chosen packets.
- **Mixed-key attack (CVE-2020-24587).** A receiver reassembles fragments even when they were **encrypted under different keys**, letting fragments from different security contexts be stitched together.
- **Fragment-cache attack (CVE-2020-24586).** Fragments left in the reassembly cache across (re)connections can be mixed with attacker fragments to exfiltrate or inject data.
- **Implementation flaws** (e.g. CVE-2020-26140, -26143, -26145, -26147 and others) — many stacks accepted plaintext frames, forwarded fragments they should have dropped, or mis-handled broadcast fragments, in several cases **without** the design flaws being needed.

The design flaws affect **all modern Wi-Fi security protocols, including WPA3**, because they are about frame parsing, not the cipher. Exploitation generally needs the attacker to be **on-path / within range and able to inject**, and often depends on user interaction or specific traffic, so impact ranged from packet injection to limited data exfiltration rather than wholesale decryption.

### How Kr00k worked

Kr00k (ESET, 2020 — **CVE-2019-15126**) is narrower and purely an **implementation** bug in certain Wi-Fi **chips from Broadcom and Cypress**. When a client is **disassociated** (an event an attacker can trigger with an ordinary, unprotected deauth on a non-PMF link), the affected chip clears the session PTK to all zeros as part of cleanup — but **frames still sitting in the chip's transmit buffer are then sent encrypted with that all-zero key**. An attacker who captures those few buffered frames can decrypt them trivially. It is a small leak per disassociation (a handful of buffered frames), repeatable by forcing repeated disassociations, scoped to the vulnerable chips. It is **not** a passphrase recovery and **not** a full session decryption.

### Affected scope and versions

- **FragAttacks:** testing covered 75+ devices and found every one affected by at least one flaw; the classes span Windows, Linux, Android, macOS, and iOS (NetBSD/OpenBSD were noted as not accepting A-MSDUs). Datable targets: pre-2021 stacks and firmware before the coordinated May-2021 disclosure fixes.
- **Kr00k:** ESET estimated **1 billion+** devices across clients (Amazon, Apple, Google, Samsung, Raspberry Pi, Xiaomi) and some APs (Asus, Huawei) built on the affected Broadcom/Cypress chips. It is bounded to those chip families; devices on other chips were not affected by this specific bug.

### Mitigation and patch status

Both were **coordinated disclosures with patches**. Kr00k was fixed by Broadcom/Cypress and pushed through device vendors around the February-2020 disclosure. FragAttacks fixes shipped across OS vendors, the Linux kernel/`wpa_supplicant`, and device firmware around the May-2021 disclosure, including Wi-Fi Alliance guidance to validate fragment handling. Current, updated OS and firmware are **not** exposed to either class. The residual risk is the same shape as KRACK: **unpatched or abandoned firmware and embedded/IoT devices**, especially (for Kr00k) anything still on an unpatched affected chip.

### What to verify now

Both reduce to checks, not exploits:

- **FragAttacks:** determine the device's OS/firmware build and whether it is at or past the vendor's 2021 FragAttacks fix (several CVEs — cite the device's advisory status rather than one CVE). For implementation flaws, the vendor advisory is the authority on which were fixed.
- **Kr00k:** first a **chipset** question — does the device use an affected **Broadcom/Cypress** chip? — then a **firmware** question: is it past the 2020 fix? A device on an unaffected chip was never vulnerable to this bug; an affected chip with pre-2020 firmware is exposed.

### Blue-team view

For defenders the standing lesson is again **patch currency plus end-to-end protection**: FragAttacks' injection/exfiltration and Kr00k's small clear-key leak are both blunted when upper-layer TLS/VPN protect the actual data, and both are closed by current firmware. Kr00k also gives a concrete bonus argument for **PMF**: because the leak is triggered by a disassociation, a PMF-required network (where forged deauth/disassoc is rejected, [12.1](lesson-01.md)) removes the easy attacker trigger even before the chipset patch — a neat vulnerable-vs-hardened point, though the real fix is the firmware update.

## Hands-on

### Guided walkthrough — two advisories, two checks (path R)

Reading/analysis exercise: you extract scope from advisories and write checks. You exploit nothing.

1. From the FragAttacks reference, write one sentence each for the three **design** flaws (aggregation CVE-2020-24588, mixed-key CVE-2020-24587, fragment-cache CVE-2020-24586) and one sentence noting the separate **implementation** flaws, plus the fact that the design flaws reach WPA3.
2. From the Kr00k reference, write the mechanism (disassociation → all-zero PTK → buffered frames sent under the zero key), the **affected chip families** (Broadcom/Cypress), and the CVE (CVE-2019-15126).
3. For one **owned** device, draft the **FragAttacks check**: OS/firmware build vs the vendor's 2021 advisory status; pass/fail format.
4. For one **owned** device, draft the **Kr00k check**: first identify the Wi-Fi chip (does it belong to the affected Broadcom/Cypress families?), then firmware vs the 2020 fix; pass/fail format, including "unaffected chip → not vulnerable to this bug."
5. Note the one defence that reduces the Kr00k **trigger** regardless of chipset patch, and why it is a mitigation of the trigger, not the bug.

> [!NOTE]
> **Lab paths:** R only (read the two advisories and produce two written checks — no hardware, no exploitation). Neither FragAttacks nor Kr00k is re-exploited here by design: FragAttacks needs an on-path injector and often specific traffic/interaction, and Kr00k needs a vulnerable physical chip and the capture of a few buffered frames — conditions a recorded or virtual setting does not reproduce. The objective is accurate scope and a per-device check.
> **Start state:** the FragAttacks and Kr00k references open; the ability to read one owned device's build string and identify its Wi-Fi chipset ([TOOLS.md](../../TOOLS.md)).
> **Duration:** ~20 min.
> **Artifacts:** two written checks — a FragAttacks build/advisory check and a Kr00k chipset-then-firmware check — each with a pass/fail verdict format, plus a one-line note on PMF reducing the Kr00k trigger.
> **Success criteria:** you classify each owned device as patched / unpatched / not-applicable (unaffected chip) with evidence, *not* any demonstration of either attack.
> **Cleanup:** none — nothing transmitted. Identifying a chipset and reading a build string on an **owned** device are local queries; neither check depends on a deauth or on frame injection ([00.3](../module-00/lesson-03.md)).

## Exercise

Two owned devices to assess. Device X is a current-model laptop fully updated this quarter. Device Y is a Raspberry Pi 3 running a 2019 OS image that has never been updated. For each, decide whether FragAttacks and Kr00k are concerns, state the specific evidence you would collect, and explain why "both bugs affect basically every Wi-Fi device" is not the conclusion you would write.

<details>
<summary>Hint</summary>

Kr00k is bounded to specific Broadcom/Cypress chips and fixed in 2020; the Raspberry Pi 3 is one of ESET's named affected devices. FragAttacks is near-universal by design but patched in 2021. For each device, the real questions are "affected chip?" and "build past the fix?" — not the headline.
</details>

<details>
<summary>Reference answer</summary>

**Device X (laptop, updated this quarter):** report **not exposed** to either class. Its OS/firmware is past both the 2021 FragAttacks fixes and (if it even uses an affected chip) the 2020 Kr00k fix. Evidence: the OS/firmware build and date shown to be at or past the vendors' advisory fixes; for Kr00k, identify the chip — if it is not a Broadcom/Cypress affected part, Kr00k is **not applicable** regardless of patching. Wording: "patched/not-applicable, not exposed," not "affects every device."

**Device Y (Raspberry Pi 3, 2019 image, never updated):** report **potential exposure to both**. The Pi 3 is one of ESET's **named Kr00k-affected devices** (Broadcom/Cypress chip), and a 2019 image predates the Kr00k fix, so buffered frames could leak under the all-zero key after a disassociation; a pre-2021 image also predates the FragAttacks fixes. Evidence: the chip identification (affected family) and the image date vs the 2020/2021 fixes. Remediation: update the OS image/firmware (the real fix); as an interim trigger-reducer for Kr00k, note that a **PMF-required** network rejects the forged disassociation that triggers the leak ([12.1](lesson-01.md)), and isolate the device on a segmented SSID/VLAN. The conclusion is a **per-device verdict with evidence** — affected chip/old build on Device Y, patched or not-applicable on Device X — never a blanket "every Wi-Fi device is broken."
</details>

## References

- [FragAttacks — fragattacks.com](https://www.fragattacks.com/) — Vanhoef, 2021: the design vs implementation flaws, the CVEs, and the tested-device scope.
- [ESET — Kr00k (CVE-2019-15126)](https://www.welivesecurity.com/2020/02/26/kr00k-serious-vulnerability-affected-encryption-billion-wifi-devices/) — the all-zero-key mechanism, affected chips, and scale.
- [ESET — Kr00k technical overview](https://www.eset.com/int/kr00k/) — the affected Broadcom/Cypress chip families and tested devices.
- [12.2 · KRACK](lesson-02.md) — the patched-class / per-device-check habit this lesson reuses.
- [12.1 · PMF and 802.11w](lesson-01.md) — why PMF removes the forged-disassoc trigger Kr00k relies on.

## What you should now be able to do

- Describe the FragAttacks aggregation, mixed-key, and fragment-cache design flaws and the separate implementation flaws, and that the design flaws reach WPA3.
- Explain Kr00k as a chipset buffer bug that sends buffered frames under an all-zero key after disassociation, scoped to Broadcom/Cypress chips.
- Produce a FragAttacks build/advisory check and a Kr00k chipset-then-firmware check, and report each as a patched class with a per-device verdict.
