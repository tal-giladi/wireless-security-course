---
id: "15.2"
module: 15
minutes: 16
practice_minutes: 0
prerequisites: ["01.1"]
objectives:
  - Describe at a high level what Zigbee and Thread are and the security concerns of 802.15.4-based mesh IoT.
  - Describe what RFID and NFC are and the security concerns of proximity access cards and payments.
  - State that these are separate protocols outside this course's hands-on scope and name where to go deeper safely.
volatility: concept
sources:
  - title: "Connectivity Standards Alliance — Zigbee and Matter (security overview)"
    url: https://csa-iot.org/all-solutions/zigbee/
  - title: "Thread Group — Thread network fundamentals and security"
    url: https://www.threadgroup.org/What-is-Thread/Overview
  - title: "NXP — MIFARE product security (Classic/Crypto1 vs DESFire AES)"
    url: https://www.nxp.com/products/rfid-nfc/mifare-hf:MIFARE_HF
last_verified: "2026-10-01"
---

# 15.2 · Zigbee, Thread, RFID, and NFC

Beyond Wi-Fi and Bluetooth, two more families of short-range radio turn up constantly in buildings a wireless tester is asked about: the **802.15.4 mesh** protocols (Zigbee and Thread) that run smart-home and IoT networks, and the **proximity** technologies (RFID and NFC) behind access badges and contactless payments. This elective lesson is **awareness only** — one section each on what they are, the security concerns at a high level, and where to go deeper safely on your own equipment. There is no attack lab here by design.

## Why this matters

These protocols share physical space, and sometimes a client's whole "wireless" question, with Wi-Fi — but they are entirely separate stacks with their own security models, and none of this course's 802.11 skills transfer to them. When a client asks about the smart lighting, the door badges, or the contactless payment readers, you need to recognise the protocol, describe the real risk classes honestly (for example that legacy access-card crypto is broken while modern cards are not), and avoid the two classic mistakes: dismissing them because "it's not Wi-Fi," or overclaiming an attack you have not scoped. Knowing where the genuine, well-documented weaknesses are — and where this course stops — lets you give a client a straight answer and a sensible referral. Badge for this lesson: **F — Foundational (awareness).**

## Learning objectives

- Describe, at a high level, what **Zigbee** and **Thread** are and the security concerns of 802.15.4-based mesh IoT.
- Describe what **RFID** and **NFC** are and the security concerns of proximity access cards and contactless payments.
- State that these are separate protocols outside this course's hands-on scope, and name reputable places to go deeper safely.

## Prerequisites

- [01.1 · Radio basics for hackers — spectrum, power, and antennas](../module-01/lesson-01.md) — the band/propagation framing and the "radio crosses property lines, and the law follows the interception not the wire" reasoning apply to every protocol below.

## Concept

### Zigbee and Thread — 802.15.4-based mesh IoT

Both **Zigbee** and **Thread** are low-power wireless **mesh** networks built on the IEEE **802.15.4** radio (mostly 2.4 GHz), used for home and building IoT: lights, sensors, locks, thermostats. In a mesh, mains-powered devices relay for battery-powered ones, extending range without a single central AP. The key difference is the upper layers: **Zigbee** defines its own application layer (the Zigbee Cluster Library), while **Thread** runs **IPv6 over 6LoWPAN**, so Thread devices are individually IP-addressable — and Thread is one of the two radios (with Wi-Fi) underneath **Matter**, the current cross-vendor smart-home standard.

Security-wise, both encrypt with **128-bit AES** and authenticate devices with network/link keys, so the modern baseline is reasonable on paper. The concerns are mostly around **commissioning** (how a new device joins and receives keys) and **legacy/implementation** weakness: Zigbee's older **Touchlink** commissioning has abused a well-known transport key; weak or default keys, replay and injection of 802.15.4 frames, and insecure join flows have all been demonstrated. For Thread/Matter the attack surface centres on commissioning too — an open commissioning window, BLE-MITM during initial Matter setup, or setup-code reuse. The practical blue-team takeaways are the familiar ones: keep firmware current, close commissioning windows, and avoid devices that ship default or weak keys.

### RFID — proximity identification and access cards

**RFID** (Radio-Frequency IDentification) covers tags read at a distance by a reader powering them over radio. The security-relevant category is **access control**: the proximity cards and fobs that open doors. Two generations matter. **Low-frequency 125 kHz** cards (e.g. older EM/HID Prox) often transmit a **static ID with no cryptography at all** — trivially cloned by holding a reader near the card. **High-frequency 13.56 MHz** cards include the widely deployed **MIFARE Classic**, whose proprietary **Crypto1** cipher has been **broken since 2008**; practical key-recovery and full cloning are well documented with inexpensive hardware. The honest message to clients: a great many building-access cards in service today are **clonable**, and the fix is migration to modern cards — **MIFARE DESFire (EV1/EV2/EV3)** and similar use standard **AES** with mutual authentication and have no publicly known practical cloning attack when correctly deployed. The weakness is almost always the **legacy card technology and its deployment**, not radio magic.

### NFC — a close cousin at very short range

**NFC** (Near-Field Communication) is a 13.56 MHz subset of RFID standardised for very short range (a few centimetres) and two-way exchange — the technology in phone "tap" features, transit cards, and contactless payments. Its short range is a meaningful (though not absolute) mitigation: an attacker generally has to get very close. Security concerns include **cloning/emulation** of weakly protected tags (the same MIFARE Classic issues reach NFC), **relay attacks** that extend range by forwarding the exchange between a victim card and a distant reader, and **eavesdropping** at close quarters. **Payment** systems (EMV contactless) layer their own cryptographic transaction protection on top, so "an NFC card can be read" is not the same as "a payment can be forged" — a distinction worth stating carefully, much as this course distinguishes capturing a frame from breaking the crypto. For many deployments the right fix is, again, moving off legacy tag technology and configuring the application-layer protections.

### Where this course stops — and the boundary

All of the above is **awareness** material: there is **no Zigbee, Thread, RFID, or NFC attack lab** in this course, by design. Going deeper is legitimate, but only on your **own** equipment or with explicit authorisation. Reading another organisation's badge, cloning a card you were not given, or injecting into someone's Zigbee mesh is unauthorised access and/or interception, and the rules vary by jurisdiction exactly as they do for Wi-Fi ([00.3](../module-00/lesson-03.md)). Reputable starting points for owned-device learning are in the References.

## Hands-on

This is a **path R, awareness** lesson with **no attack lab and no owned-device transmission exercise** — by design (see the awareness scope above). The practical skill is **recognition and classification**, which you can do from the information you already have about a site, without any specialist hardware.

### Guided walkthrough — classify the non-Wi-Fi radios at a site (paper exercise)

1. Take a short inventory from a building you know (your home counts): list each non-Wi-Fi wireless device you can think of — smart bulbs, a door badge, a contactless card, a thermostat, a tracker.
2. For each, name the **likely protocol family**: 802.15.4 mesh (Zigbee/Thread/Matter), BLE ([15.1](lesson-01.md)), or RFID/NFC. A hub app or a product spec usually tells you.
3. For each, write the **headline security concern** from the Concept — e.g. "125 kHz prox badge → static ID, clonable"; "smart bulb on Zigbee → check commissioning and default keys"; "contactless payment → EMV protection on top, don't overclaim."
4. Mark which, if any, would need a **separate, specialist, authorised engagement** rather than this Wi-Fi course's techniques. That list is the honest scope boundary you would give a client.

> [!NOTE]
> **Lab paths:** R only (a paper classification exercise from site knowledge — no hardware, no radio transmission, no attack). **Proves:** you can recognise and name the non-Wi-Fi radio families and state their headline risk class. **Does not prove:** any capture, cloning, injection, or exploitation of Zigbee, Thread, RFID, or NFC — none is performed or credited here.
> **Start state:** knowledge of one building's devices (your own).
> **Duration:** ~10 min (counts as reading; `practice_minutes` is 0 — no hands-on radio work).
> **Artifacts:** a short table of device → protocol family → headline concern → in-scope-here or specialist.
> **Cleanup:** none — nothing was transmitted or touched.

## Exercise

A facilities manager says: "Our door badges are RFID and our lighting is Zigbee — can your Wi-Fi test cover them, and are they secure?" Without running any attack, write the answer you would give: whether your Wi-Fi engagement covers them, the one headline security question you would ask about each, and how you would avoid both dismissing them and overclaiming.

<details>
<summary>Hint</summary>

Separate "same building" from "same protocol." For the badges, the decisive question is *which card technology* — the answer differs enormously between a 125 kHz prox card, MIFARE Classic, and DESFire. For the lighting, think about how devices joined the mesh and what keys they hold. Then frame scope the way you would for any protocol you are not contracted or equipped to attack.
</details>

<details>
<summary>Reference answer</summary>

**Scope.** A Wi-Fi engagement does **not** automatically cover RFID badges or a Zigbee mesh — they are separate protocols, 802.15.4 and proximity RF, not 802.11, and none of the Wi-Fi techniques apply. You say so plainly and offer to scope them as a separate, specialist assessment rather than silently skipping them or pretending the Wi-Fi tools reach them.

**Headline question — badges.** *Which card technology?* If they are 125 kHz prox or MIFARE Classic, the honest finding is that the cards are clonable with inexpensive, well-documented tooling and the remediation is migration to AES-based cards such as DESFire. If they are already DESFire (or similar) and correctly deployed, there is no known practical cloning attack — a genuine pass. You do not need to clone a card to raise the finding, just as you do not need to crack a cipher to report a deprecated one.

**Headline question — Zigbee lighting.** *How did devices join, and do they use default or weak keys?* Commissioning (including legacy Touchlink) and default/weak keys are the recurring weak points; the baseline fix is current firmware, closed commissioning windows, and no default keys.

**Avoiding both errors.** Not dismissing: these carry real, documented risk (especially legacy access cards). Not overclaiming: you frame each as a *class to examine under authorisation on owned equipment*, note that payment systems layer their own protections, and refer deep work to a properly scoped specialist engagement — the same discipline you apply to any attack you have not scoped.
</details>

## References

- Connectivity Standards Alliance — Zigbee and Matter security overview (`../../references/README.md`).
- Thread Group — Thread fundamentals and security model (`../../references/README.md`).
- NXP — MIFARE product security: Classic/Crypto1 (legacy) versus DESFire AES (`../../references/README.md`).
- [15.1 · BLE and Bluetooth — scope and where to go deeper](lesson-01.md) — the other adjacent short-range radio.
- [00.3 · Safety, containment, and the law](../module-00/lesson-03.md) — owned/authorised equipment only; interception and unauthorised-access law.

## What you should now be able to do

- Describe, at a high level, what Zigbee and Thread are and the security concerns of 802.15.4-based mesh IoT (commissioning, legacy/weak keys).
- Describe what RFID and NFC are and the security concerns of proximity access cards (legacy static/Crypto1 cards are clonable; AES cards are not) and contactless payments.
- Recognise and classify the non-Wi-Fi radios at a site, state the honest scope boundary, and point to reputable owned-device resources for going deeper.
