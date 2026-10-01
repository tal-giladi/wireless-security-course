---
id: "02.1"
module: 2
minutes: 25
practice_minutes: 20
prerequisites: ["01.4"]
objectives:
  - Distinguish Open, OWE, WPA2-Personal, WPA3-SAE, and WPA2/3-Enterprise by what each authenticates and encrypts.
  - Explain precisely what OWE and PMF do and do not provide.
  - Read a beacon's RSN information to recognise which security option an AP advertises, including transition mode.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (RSN, SAE, PMF)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wi-Fi Alliance — WPA3 Specification (SAE, transition mode, PMF, OWE)"
    url: https://www.wi-fi.org/discover-wi-fi/security
  - title: "RFC 8110 — Opportunistic Wireless Encryption (OWE)"
    url: https://www.rfc-editor.org/rfc/rfc8110
last_verified: "2026-10-01"
---

# 02.1 · The protocol family — Open, OWE, WPA2, WPA3, Enterprise, and PMF

Before you can attack or defend a wireless network you have to know exactly what it is doing, because every option in the Wi-Fi security family makes a different promise about who is authenticated and what is encrypted. This lesson maps the whole family — Open, OWE, WPA2-Personal, WPA3-SAE, the Enterprise variants, and the management-frame protection that sits across them — and shows you how to read an access point's advertised security straight out of a beacon so you never have to guess.

## Why this matters

Almost every decision you make later in the course starts with one question: what is this network running? A WPA2-Personal network and a WPA3-SAE network look identical to a user, but one hands you an offline-crackable handshake and the other does not. An "Open" network and an OWE network both show no password prompt, but one is readable by anyone in range and the other is not. Getting the family straight now means that when you read a capture in Module 5, attack WPA2 in Module 6, or assess WPA3 in Module 7, you already know what is on the table and what is off it. Misreading the protocol is the fastest way to waste hours attacking a weakness that is not there — or to miss the one that is.

## Learning objectives

- Distinguish Open, OWE, WPA2-Personal, WPA3-SAE, and WPA2/3-Enterprise by what each authenticates and what each encrypts.
- State precisely what OWE provides (encryption without network authentication) and what PMF/802.11w protects (management frames, with limits).
- Read the RSN information in a beacon or probe response to recognise which security option an AP advertises, and spot WPA3/WPA2 transition mode.

## Prerequisites

- Lesson 01.4 — joining a network: beacons, probe responses, authentication, and association. This lesson reads the security fields of the same frames you met there.

## Concept

### The two questions every security mode answers

Every Wi-Fi security option is really an answer to two separate questions, and keeping them apart prevents most confusion in this course:

1. **Is the traffic encrypted over the air?** (Can someone in range read your packets?)
2. **Is anything authenticated — and if so, what: the network, the client, or both?** (Do you know you are talking to the real AP, and does the AP know who you are?)

"Open" says no to both. OWE says yes to encryption, no to authentication. WPA2/WPA3-Personal authenticate *knowledge of a shared passphrase* on both sides. Enterprise authenticates an *individual identity* against a server. Hold those two questions in mind as we walk the family.

### How it works on the wire — the RSN element

An AP advertises its security in its **beacons** and **probe responses** using the **Robust Security Network Element (RSNE)**, defined in IEEE 802.11. You do not read it as English; you read three fields inside it:

- **The group cipher** — used for broadcast/multicast (typically CCMP-128/AES; TKIP only on legacy networks).
- **The pairwise cipher(s)** — used for unicast (CCMP for anything modern).
- **The Authentication and Key Management (AKM) suite(s)** — *this is the field that tells you the security mode.* The AKM selector says whether the network uses a pre-shared key, SAE, 802.1X, OWE, and so on.

A fourth piece, the **RSN Capabilities** bits, carries the **PMF** flags (described below). An Open network has *no RSNE at all* (or, for OWE, a specific AKM inside one). This is why a tool like `airodump-ng` or Wireshark can label a network WPA2/WPA3/OWE purely from a passive beacon — it is decoding the AKM selector, not probing the AP.

### The family, one by one

**Open (no security).** No RSNE, no encryption, no authentication. Every frame is cleartext and anyone in monitor mode reads it. Still common on legacy guest and captive-portal networks. A captive portal in front of an Open network is a web login, **not** link-layer encryption — the air is still readable.

**OWE (Enhanced Open), RFC 8110.** Adds a Diffie-Hellman exchange so each client gets a unique encryption key, defeating passive sniffing on a network that has no password. Crucially, **OWE authenticates nothing** — there is no password and no server, so a client has no way to tell the real AP from a rogue one advertising the same SSID. OWE stops the passive eavesdropper on an open network; it does **not** stop an active rogue/MITM. Recognisable by the OWE AKM selector in the RSNE.

**WPA2-Personal (WPA2-PSK).** A single passphrase is shared by everyone on the network. Both sides prove they know the derived key via the 4-way handshake (Module 2.2 and Module 6). The weakness you will exploit later: a captured handshake (or a PMKID) yields material you can attack offline against a wordlist. AKM selector = PSK; pairwise cipher = CCMP.

**WPA3-SAE (WPA3-Personal).** Still one passphrase, but the key is agreed with **SAE (Dragonfly)**, a password-authenticated key exchange. The decisive difference: a passive capture of an SAE exchange yields **no offline-crackable hash** — there is nothing to feed a wordlist. (Why, in Module 2.2 and Module 7.) WPA3-SAE **requires PMF**. AKM selector = SAE.

**Transition mode (WPA3 + WPA2).** For compatibility, an AP can advertise **both** SAE and PSK AKMs in the same BSS so old and new clients both connect. This is the real downgrade surface for WPA3-Personal: a WPA2-only client (or an attacker forcing one) still negotiates PSK and still produces a crackable handshake, so the network is only as strong as its WPA2 side. You recognise it by seeing **both** the SAE and PSK AKM selectors in one RSNE.

**WPA2/WPA3-Enterprise (802.1X).** No shared passphrase. Each user authenticates an **individual identity** to a back-end **RADIUS** server via **EAP**, brokered by the AP acting as authenticator. Trust rests on certificates and server validation rather than a group secret (Modules 10–11). AKM selector = 802.1X (and SAE/802.1X-SHA256 variants for WPA3-Enterprise).

### PMF / 802.11w — protection *across* the family

**Protected Management Frames (PMF, 802.11w)** is not a separate network type; it is a capability layered onto RSN that cryptographically protects a subset of **management frames** — notably deauthentication and disassociation — so they cannot be trivially forged. Two bits in RSN Capabilities express it: **MFPC** (management-frame-protection capable) and **MFPR** (required). PMF is **optional** on WPA2, **mandatory** on WPA3-SAE, and set to *capable-but-not-required* in transition mode.

Be precise about PMF's limits: it protects robust management frames, so a classic forged-deauth denial of service is rejected on a PMF-required network — but PMF does **not** encrypt data, does not authenticate the network by itself, and does not cover every frame type. This is why, in later WPA3 labs, we **do not** make a successful deauth a prerequisite: on a PMF network it is supposed to fail, and that failure is the lesson.

### A one-screen summary

| Mode | Encrypted? | Authenticates | AKM selector you'll see | PMF |
|---|---|---|---|---|
| Open | No | Nothing | (no RSNE) | n/a |
| OWE | Yes | Nothing | OWE | typically on |
| WPA2-Personal | Yes | Shared passphrase | PSK | optional |
| WPA3-SAE | Yes | Shared passphrase (SAE) | SAE | required |
| Transition (WPA3+WPA2) | Yes | Both of the above | SAE **and** PSK | capable |
| WPA2/3-Enterprise | Yes | Individual identity (802.1X) | 802.1X | optional / required |

## Hands-on

### Guided walkthrough — reading security out of beacons

This is a reading exercise on supplied captures; no radio and no attack. Using the beacon capture shipped in `../../labs/module-02/` and opened in Wireshark (Module 5 covers the tool in depth; here you only need the display filters):

1. Open `baseline-beacons.pcapng`. Apply the display filter `wlan.fc.type_subtype == 0x08` to show only beacon frames.
2. Pick one beacon and expand **Tagged parameters → RSN Information**. Read the **Group Cipher**, **Pairwise Cipher**, and **Auth Key Management (AKM)** suite.
3. Map the AKM selector to the family table above. Is it PSK, SAE, both, 802.1X, or OWE?
4. Expand **RSN Capabilities** and read the **MFPC** and **MFPR** bits to decide the network's PMF stance.
5. Repeat for each distinct SSID in the capture and fill in a row of the table for each. One of the networks is in transition mode — find it by spotting two AKM selectors in one RSNE.

> [!NOTE]
> **Lab paths:** R — supplied beacon capture, no hardware (proves you can *interpret* advertised security). This lab does **not** prove live capture, injection, or any RF behaviour; those require the V or P paths in later modules.
> **Start state:** `baseline-beacons.pcapng` from the module zip, Wireshark installed, no lab network built.
> **Duration:** ~20 min.
> **Artifacts:** a completed family table — one row per SSID — naming each network's cipher, AKM, and PMF stance, plus a note of which SSID is transition mode and how you knew.
> **Cleanup:** none (read-only analysis).

## Exercise

You passively capture beacons from three networks with the same SSID, `CorpWiFi`, coming from three different BSSIDs. Network A advertises only the SAE AKM with MFPR set; network B advertises both SAE and PSK AKMs with MFPC set but MFPR clear; network C advertises only PSK with no PMF. Without sending a single frame, rank the three from hardest to easiest to attack offline with a wordlist, and explain what each one's RSN advertisement tells an attacker before they do anything else.

<details>
<summary>Hint</summary>

The thing a wordlist attacks is an offline-crackable handshake. Ask, for each network: does associating to it (or forcing a client onto it) ever yield PSK handshake material? SAE does not; PSK does. PMF changes whether you can force a client with a deauth, not whether the captured material is crackable.
</details>

<details>
<summary>Reference answer</summary>

Hardest is **A** (SAE-only, PMF required): SAE yields no offline-crackable hash, and PMF blocks the forged deauth you would use to speed up any capture, so there is no wordlist attack surface at all. Easiest is **C** (PSK-only, no PMF): it produces a crackable 4-way handshake and you can force a client off with a deauth to capture it quickly. **B** sits in between and is the subtle one: although it advertises SAE, it is **transition mode**, so a WPA2 client still negotiates PSK and still produces a crackable handshake — the SAE advertisement does not protect that path. PMF is only *capable* on B, so a deauth may still succeed against a non-PMF client. The lesson: the RSNE alone tells you, passively, that A has no PSK surface, C is fully exposed, and B's SAE label is undermined by its PSK fallback.
</details>

## References

- IEEE 802.11-2020 — RSN element, AKM suites, RSN Capabilities (PMF), SAE (`../../references/README.md`).
- Wi-Fi Alliance — WPA3 Specification: SAE, transition mode, PMF requirement, OWE (`../../references/README.md`).
- RFC 8110 — Opportunistic Wireless Encryption (OWE): encryption without authentication (`../../references/README.md`).
- Glossary: RSN, AKM, OWE, PMF, SAE, transition mode (`../../glossary.md`).

## What you should now be able to do

- Name the Wi-Fi security options and say, for each, whether it encrypts and what (if anything) it authenticates.
- State precisely that OWE gives encryption without authenticating the network, and that PMF protects management frames with defined limits.
- Read the AKM selector and PMF bits in a beacon's RSN information to identify a network's security — including recognising WPA3/WPA2 transition mode.
