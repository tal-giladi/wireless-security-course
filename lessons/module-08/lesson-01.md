---
id: "08.1"
module: 8
minutes: 16
practice_minutes: 20
prerequisites: ["06.1"]
objectives:
  - Describe the WPS registrar/enrollee roles and where the external-registrar PIN method sits in the association flow.
  - Explain the 8-digit PIN structure and the split-half validation that is the root design flaw behind every WPS PIN attack.
  - Distinguish push-button (PBC) from PIN onboarding and state why PIN is the attackable method.
volatility: concept
sources:
  - title: "Wi-Fi Alliance — Wi-Fi Protected Setup specification overview (registrar/enrollee, PIN and PBC methods)"
    url: https://www.wi-fi.org/discover-wi-fi/wi-fi-protected-setup
  - title: "Viehbock (2011) — Brute forcing Wi-Fi Protected Setup (the split-PIN design flaw)"
    url: https://sviehb.files.wordpress.com/2011/12/viehboeck_wps.pdf
last_verified: "2026-10-01"
---

# 08.1 · How WPS works

Wi-Fi Protected Setup was meant to spare home users from typing a long WPA2 passphrase, and in doing so it added an 8-digit PIN path whose validation design is the single reason every WPS attack in this elective module exists. This foundation lesson introduces the registrar and enrollee roles, walks where the external-registrar PIN exchange sits relative to normal association, and shows how the PIN is split into two independently-checked halves — the flaw you need to understand before the Pixie Dust and online-brute lessons make sense.

## Why this matters

WPS is an **elective** topic because it is a convenience feature bolted onto WPA2, not part of the cryptography you spent Module 6 on. But it is still enabled by default on a large share of home and small-office routers, and when it is weak it hands an attacker the full WPA2 passphrase without touching the handshake at all. You cannot assess that risk — or advise a client to turn it off — unless you can explain what WPS actually does: who the registrar and enrollee are, what the PIN proves, and why cutting the PIN in half was the mistake that made it brute-forceable. Everything in 08.2–08.4 is a consequence of this one design.

## Learning objectives

- Describe the **registrar**/**enrollee** roles and where the external-registrar **PIN** method sits in the association flow.
- Explain the **8-digit PIN** structure and the **split-half** validation that is the root design flaw.
- Distinguish **push-button (PBC)** from **PIN** onboarding and state why PIN is the attackable method.

## Prerequisites

- [06.1 · The 4-way handshake in depth](../module-06/lesson-01.md) — WPS ends by delivering the WPA2 credential, so you need to know what that credential is and what the 4-way handshake does with it.

## Concept

### How it works on the wire

WPS defines two roles for onboarding a device onto a protected network:

- The **registrar** holds the network credential and can give it out — usually the AP itself (an "internal registrar"), but the protocol also allows an **external registrar** that proves it is authorised by knowing the AP's PIN.
- The **enrollee** is the device that wants to join and receive the credential.

The exchange runs as an **EAP** conversation (messages M1–M8) carried in 802.11 data frames *after* the client has done ordinary open-system authentication and association (lesson 06.1's join flow). WPS does not replace the 4-way handshake; it is a **credential-delivery** protocol that runs first and ends by handing the enrollee the WPA2 passphrase (PSK), after which the device associates normally and runs the handshake you already know. The security question is therefore entirely about **what proves you are allowed to receive that passphrase.**

### The two onboarding methods

The specification offers more than one method; two matter here:

- **Push-button (PBC).** The user presses a physical (or virtual) button on the AP and on the client within a short window. Possession of physical access is the "proof." There is no secret to brute-force — PBC's weakness is a narrow timing/active-session window, not an offline-guessable value — which is exactly why the attacks in this module target the **PIN** method, not PBC.
- **PIN.** An 8-digit number (often printed on a label under the router) is entered to authorise the join. When an **external registrar** presents the correct PIN to the AP, the AP will release the network credential. This is the method with the exploitable design flaw.

### Why the weakness exists — the split PIN

The 8-digit PIN is not validated as one 8-digit number. Of the eight digits, the **last digit is a checksum** computed from the first seven, so there are really **10^7 = 10,000,000** possible PINs. That alone would be slow to guess online. The fatal design choice is that the AP validates the PIN **in two halves and tells you, mid-protocol, whether the first half was right** before you have committed to the second:

- The **first half** is 4 digits → **10^4 = 10,000** possibilities.
- The **second half** is the remaining 3 meaningful digits (the 4th being the checksum) → **10^3 = 1,000** possibilities.

Because a wrong first half produces a distinguishable failure (the AP rejects at a point that reveals the first half was wrong) separately from a wrong second half, an attacker never searches the full 10,000,000 space. They search **10,000 + 1,000 = 11,000** — a catastrophic reduction. This is the Viehböck (2011) result and the root cause of the online brute force (lesson 08.3). A later, worse problem — some APs leaking enough to recover the PIN **offline** from a single exchange — is the Pixie Dust attack (lesson 08.2); it is a different bug on top of the same PIN method.

> [!NOTE]
> WPS appears in the OSWP / PEN-210 syllabus ("Attacking WPS"), which is why this elective exists. Per the course's modernity rule, the **online PIN brute** is covered as summary-only legacy (08.3) because modern APs mostly mitigate it, while **Pixie Dust** (08.2) keeps a full lesson because it still works against vulnerable implementations.

## Hands-on

### Guided walkthrough — find WPS in a capture (path R)

You do not need any WPS hardware to see how a network advertises it. WPS presence is announced in a **vendor-specific WPS information element** inside the AP's beacon and probe responses.

1. Open the supplied `wps-beacon.pcapng` (recorded path) in Wireshark and filter beacons: `wlan.fc.type_subtype == 0x08`.
2. Expand the tagged parameters and find the **WPS / Wi-Fi Protected Setup** vendor-specific element (Microsoft/Wi-Fi Alliance OUI). Note the fields that matter for later lessons: **Version**, **Config Methods** (does it list PIN, PBC, or both?), **AP Setup Locked** (is WPS currently locked out?), and the **Device Name/Model** (which hints at the chipset — relevant to Pixie Dust in 08.2).
3. In `airodump-ng`, the same information shows as a `WPS` column when you add WPS detection — a one-line way to spot WPS-enabled APs during recon (Module 4). Compare: a beacon with a WPS IE and `AP Setup Locked: False` is a candidate; one advertising only PBC, or with WPS locked, is not an online-brute candidate.

> [!NOTE]
> This lesson transmits nothing and needs no adapter. You are reading a recorded beacon to learn what WPS looks like on the wire, not engaging a registrar.

### Lab

> [!NOTE]
> **Lab paths:** R (supplied `wps-beacon.pcapng` — no hardware; proves you can recognise a WPS-enabled AP and read its config methods and lock state from a beacon. It does **not** prove live interaction with a registrar — that needs a real AP and is covered in 08.2.)
> **Start state:** recorded toolchain (Wireshark/`tshark`) + the module zip; no radio required.
> **Duration:** ~20 min.
> **Artifacts:** a note of the capture's WPS IE fields — Version, Config Methods (PIN/PBC), AP Setup Locked, and the device/model string — and a one-sentence judgement of whether the AP is a PIN-attack candidate.
> **Success criteria:** you locate the WPS information element in a beacon, read its config methods and lock state, and correctly state whether the PIN method is advertised (and therefore in scope for 08.2/08.3) or not.
> **Troubleshooting:** no WPS element found (the AP in that frame does not run WPS — check you filtered beacons and expanded tagged parameters); airodump shows a blank WPS column (WPS scanning not enabled, or the AP hides it — read the beacon directly); you see only PBC in config methods (PIN is not offered, so the PIN attacks do not apply — note that as the finding).
> **Cleanup:** none — the recorded path writes nothing over the air. Delete scratch exports if you made any. (`../../labs/common/reset-lab.sh` is only needed on the V/P paths used in 08.2.)

## Exercise

A router's label shows an 8-digit WPS PIN. A colleague argues: "Eight digits is a hundred million combinations, so brute-forcing the PIN online would take years — WPS PINs are effectively safe." Without yet introducing any tool, explain exactly why this reasoning is wrong, how many guesses are actually required, and what property of the AP's responses makes that reduction possible. Then state the one onboarding method that does **not** share this flaw and why.

<details>
<summary>Hint</summary>

Count the real keyspace: what does the eighth digit do, and is the PIN checked as one number or in parts? Think about what the AP reveals between the two halves. For the safe method, ask what the attacker would have to brute-force if there is no secret PIN at all.
</details>

<details>
<summary>Reference answer</summary>

The "hundred million" figure is wrong twice over. First, the **eighth digit is a checksum** of the first seven, so there are only 10^7 = 10,000,000 valid PINs, not 10^8. Second — and decisively — the AP does **not** validate the PIN as a single number: it checks the **first 4 digits and the second half separately**, and a wrong first half fails at a distinguishable point from a wrong second half. That lets an attacker brute-force the first half (10^4 = 10,000) and then the second half (10^3 = 1,000, since the last digit is the checksum) **independently**, for a total of just **11,000** guesses instead of ten million. The reduction is possible because the protocol leaks, mid-exchange, whether the first half was correct. The method that does **not** share this flaw is **push-button (PBC)**: there is no PIN secret to guess, so there is nothing to brute-force offline or online — its weakness is only the short active-session/timing window, which is why the PIN method, not PBC, is the target of 08.2 and 08.3.
</details>

## References

- [Wi-Fi Alliance — Wi-Fi Protected Setup overview](https://www.wi-fi.org/discover-wi-fi/wi-fi-protected-setup) — registrar/enrollee roles, PIN and PBC methods.
- [Viehböck (2011) — Brute forcing Wi-Fi Protected Setup](https://sviehb.files.wordpress.com/2011/12/viehboeck_wps.pdf) — the original split-PIN design-flaw disclosure.
- [06.1 · The 4-way handshake in depth](../module-06/lesson-01.md) — the WPA2 credential that WPS delivers and the handshake that follows.

## What you should now be able to do

- Describe the registrar and enrollee roles and where the external-registrar PIN exchange sits relative to normal association.
- Explain the 8-digit PIN's checksum and split-half validation, and why that reduces the search to 11,000 guesses.
- Tell PBC from PIN onboarding and say why the PIN method — not PBC — is what the next lessons attack.
