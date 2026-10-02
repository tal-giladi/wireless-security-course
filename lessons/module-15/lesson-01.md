---
id: "15.1"
module: 15
minutes: 16
practice_minutes: 10
prerequisites: ["01.1"]
objectives:
  - Describe at a high level what BLE and classic Bluetooth are and how their pairing and GATT model works.
  - Name the common classes of BLE security issue without needing to run an attack.
  - Identify reputable places to go deeper safely on owned devices, and state the owned-devices-only legal boundary.
volatility: concept
sources:
  - title: "NIST SP 800-121 Rev. 2 — Guide to Bluetooth Security"
    url: https://csrc.nist.gov/pubs/sp/800/121/r2/upd1/final
  - title: "Bluetooth SIG — Bluetooth security (pairing, LE Secure Connections)"
    url: https://www.bluetooth.com/learn-about-bluetooth/key-attributes/bluetooth-security/
last_verified: "2026-10-01"
---

# 15.1 · BLE and Bluetooth — scope and where to go deeper

Bluetooth, and especially Bluetooth Low Energy (BLE), is the other radio on almost every device you own, and it sits next to Wi-Fi in the same 2.4 GHz band — so a wireless tester is repeatedly asked about it. This elective lesson is **awareness only**: it gives you enough of the BLE security model to reason about the risks and talk to clients sensibly, names the kinds of issue that exist, and points you to reputable resources to go deeper on **your own** devices — without a deep attack lab, which is out of scope for this course by design.

## Why this matters

When you scope a wireless engagement, clients often conflate "wireless" with "Wi-Fi" and then ask, almost as an afterthought, about the smart lock, the medical wearable, or the asset tracker in the building — all of which speak BLE, not 802.11. You need to recognise that these are a **different protocol with a different security model**, say honestly whether they are in scope, and describe the real risk classes (weak pairing, unprotected GATT reads/writes, tracking) without overclaiming. You also need to know where this course stops: we do not teach BLE exploitation, and the right move is to point the learner to focused, reputable BLE material rather than improvise. Badge for this lesson: **F — Foundational (awareness).**

## Learning objectives

- Describe, at a high level, what BLE and classic Bluetooth are and how pairing and the **GATT** data model work.
- Name the common classes of BLE security issue — insecure pairing, open GATT attributes, and device tracking — without running an attack.
- Identify reputable resources for going deeper **on owned devices**, and state the legal boundary that keeps that lawful.

## Prerequisites

- [01.1 · Radio basics for hackers — spectrum, power, and antennas](../module-01/lesson-01.md) — you need the 2.4 GHz band and "radio does not respect walls or property lines" framing; BLE lives in the same band and the same containment and legal reasoning applies.

## Concept

### What BLE and classic Bluetooth are

"Bluetooth" is really two technologies sharing a brand. **Classic Bluetooth (BR/EDR)** is the older, higher-throughput mode behind audio streaming and file transfer. **Bluetooth Low Energy (BLE)**, introduced in Bluetooth 4.0, is a separate stack optimised for tiny, battery-powered sensors that wake, send a few bytes, and sleep — the technology behind most wearables, beacons, smart-home sensors, and trackers. Both operate in the 2.4 GHz ISM band alongside Wi-Fi, but they are **not 802.11**: different framing, different pairing, different data model, and none of the Wi-Fi tools from this course apply to them. For a tester, the first job is simply recognising that a "wireless" device may not be a Wi-Fi device at all.

### The security model — pairing and GATT

BLE's security is built around **pairing**, the process that establishes keys between two devices. The pairing method chosen decides how much protection you get. **LE Secure Connections** (Bluetooth 4.2 and later) uses Elliptic-Curve Diffie-Hellman to agree a key and can authenticate it against a man-in-the-middle; the association models include **Just Works** (no authentication — convenient but offers no MITM protection), **Passkey Entry**, **Numeric Comparison**, and **Out Of Band**. The weak-but-common choice is **Just Works**, which many cheap devices ship with because they have no screen or keypad to support a stronger model.

Once paired (or often even unpaired), a BLE peripheral exposes its data through **GATT** — the Generic Attribute Profile. GATT organises a device's capabilities into **services** and **characteristics**, each a readable/writable value at a handle (battery level, a lock command, a sensor reading). A central device (your phone) discovers and interacts with these. The crucial point for security: whether a given characteristic *requires* encryption or authentication is a per-attribute setting the vendor must configure, and many do not.

### The classes of issue that exist

You do not need to run an attack to understand the recurring BLE weaknesses, all well documented:

- **Insecure pairing.** Just Works pairing gives no MITM protection, so a device within radio range during pairing can interpose. Some devices also allow re-pairing on demand or hold keys poorly.
- **Unprotected GATT.** Characteristics left readable or **writable without authentication** mean a nearby device can read sensor data or send commands (a toy example repeated across real products: an unauthenticated "unlock" characteristic). This is the single most common real-world finding.
- **Plaintext data.** When the Security Manager is never configured, traffic — and sometimes credentials or personal data — crosses the air in the clear, readable by a passive sniffer.
- **Device tracking / privacy.** Even without breaking anything, a device that advertises a stable address or a distinctive GATT fingerprint can be followed around a space. BLE defines address randomisation to counter this, but not every device uses it correctly.

Classic Bluetooth has its own history (e.g. the **BlueBorne** class of implementation flaws), but BLE is where most current IoT exposure lives because that is where the cheap, under-engineered devices are.

### Where this course stops — and the legal line

This is an **awareness** lesson: there is **no BLE attack lab** here, by design (§2 of the course plan treats adjacent wireless as awareness only). Going deeper is worthwhile, but only within the same rule that governs every offensive page in this course — **you work on equipment you own or are explicitly authorised to test**. Sniffing, pairing with, or sending writes to someone else's BLE device is the same category of act as attacking someone else's Wi-Fi: interception and unauthorised access laws apply, and they vary by jurisdiction (see [00.3](../module-00/lesson-03.md)). Reputable places to learn hands-on on *your own* devices appear in the References.

## Hands-on

This is a **path R, awareness** lesson. There is **no attack lab** — the only hands-on step is a safe, passive observation of **your own** BLE devices with a phone app, to make the pairing/GATT model concrete.

> [!WARNING]
> **Owned devices only.** Observe and connect to **only** BLE devices you own or are explicitly authorised to touch. A BLE scanner is passive when it only lists advertisements, but *connecting* to and reading a peripheral is an interaction — keep it to your own earbuds, fitness band, or a smart bulb you bought for this. Do not connect to, probe, or record other people's devices; interception and unauthorised-access law applies exactly as it does for Wi-Fi ([00.3](../module-00/lesson-03.md)).

### Guided walkthrough — see advertisements, services, and characteristics on your own device

1. Install a reputable read-only BLE scanner on a phone (for example nRF Connect for Mobile, published by Nordic Semiconductor, on Android or iOS). These apps transmit only ordinary scan/connect requests.
2. Open the scanner and look at the list of **advertising** devices around you. Note that each shows an address and often a name — and observe whether your own device's address looks random (privacy) or fixed.
3. Select one device **you own** and connect. Expand its **GATT** tree: you will see **services**, and under each, **characteristics** with properties like Read, Write, Notify.
4. Read a safe characteristic on your own device — the standard **Battery Level** (service 0x180F) is a good, harmless one. Notice whether the read succeeded without any pairing prompt: that tells you the characteristic required no authentication.
5. Write down: did your device use a random or fixed address, and did reading battery level require pairing? That is the pairing/GATT model from the Concept, observed directly.

> [!NOTE]
> **Lab paths:** R only (observe your own devices with a phone scanner — no wireless-security hardware, no attack). **Proves:** you can read BLE advertisements and the GATT service/characteristic model, and reason about whether an attribute was protected. **Does not prove:** any BLE capture, injection, pairing attack, or exploitation — none is performed or credited here.
> **Start state:** a phone with a reputable BLE scanner app; one BLE device you own, powered on.
> **Duration:** ~10 min.
> **Artifacts:** a short note of one device's address type and whether battery-level read needed pairing.
> **Cleanup:** disconnect in the app; nothing was changed on the device.

## Exercise

A client asks you to "test the wireless security of our new badge system." On site you find the badges and readers are BLE, with a companion phone app. Without running any attack, write (a) why you cannot answer this with the Wi-Fi tools and techniques from this course, (b) the two or three BLE-specific risk classes you would want to investigate under a proper, authorised BLE engagement, and (c) what you would tell the client about scope and authorisation before touching anything.

<details>
<summary>Hint</summary>

Start from "is this even the protocol I was equipped for?" Then recall the recurring BLE weakness classes from the Concept — think especially about which GATT characteristics a badge reader might expose and how the badge pairs. Finally, apply the same authorisation and owned-/authorised-equipment rule you would for a Wi-Fi test.
</details>

<details>
<summary>Reference answer</summary>

**(a) Wrong protocol.** The badge system is BLE, not 802.11, so the entire Wi-Fi toolchain and the attacks in this course do not apply — monitor mode, handshakes, PMKID, evil twins are all meaningless here. Reporting "Wi-Fi looks fine" would be both true and useless; you must say plainly that this needs a BLE-specific assessment.

**(b) BLE risk classes to investigate (under authorisation).** The pairing method the badge and reader negotiate (is it Just Works, giving no MITM protection?); the GATT attributes the reader exposes (any characteristic readable or, worse, **writable** without authentication — e.g. something that influences an unlock); whether data crosses the air in the clear (Security Manager never configured); and whether badges advertise stable identifiers that allow tracking. These are the documented recurring findings, and each is a *class to examine*, not a claim that the system is broken.

**(c) Scope and authorisation.** Before touching anything you confirm written authorisation that explicitly covers the BLE devices, establish that the badges, readers, and phones in scope are the client's own equipment, and set the same containment rules as a Wi-Fi test (owned/authorised targets only, minimum transmission, stop conditions). You also disclose that deep BLE exploitation is a specialist engagement; if it is outside your contracted skills or this course's scope, you say so and scope it separately rather than improvising.
</details>

## References

- NIST SP 800-121 Rev. 2 — Guide to Bluetooth Security (pairing models, BLE security recommendations) (`../../references/README.md`).
- Bluetooth SIG — Bluetooth security: pairing and LE Secure Connections (`../../references/README.md`).
- [01.1 · Radio basics for hackers](../module-01/lesson-01.md) — the shared 2.4 GHz band and containment reasoning.
- [00.3 · Safety, containment, and the law](../module-00/lesson-03.md) — owned/authorised equipment only; interception and unauthorised-access law.

## What you should now be able to do

- Explain, at a high level, what BLE and classic Bluetooth are, and how pairing and the GATT service/characteristic model work.
- Name the common BLE security issue classes — insecure (Just Works) pairing, unprotected GATT attributes, plaintext data, and tracking — without running an attack.
- Point a learner or client to reputable BLE resources for deeper, owned-device practice, and state the authorisation and legal boundary that keeps it lawful.
