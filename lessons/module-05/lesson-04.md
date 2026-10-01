---
id: "05.4"
module: 5
minutes: 20
practice_minutes: 20
prerequisites: ["05.2"]
objectives:
  - Classify 802.11 frames by what a passive listener can read without any key.
  - Explain what CCMP protects and what it leaves in the clear on a WPA2 or WPA3 network.
  - State honestly what passive capture can and cannot recover, and where PMF changes the picture.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 — CCMP, protected frames, and the MAC header"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "Wireshark display filter reference — wlan (protected-frame flag)"
    url: https://www.wireshark.org/docs/dfref/w/wlan.html
  - title: "802.11w / Protected Management Frames (PMF) overview"
    url: https://en.wikipedia.org/wiki/IEEE_802.11w-2009
last_verified: "2026-10-01"
---

# 05.4 · Protected versus cleartext frames — what you can and cannot read

Passive capture on a secured network gives you far more than beginners expect and far less than the paranoid fear: the entire 802.11 MAC header is in the clear on every frame, but the data payload under CCMP is not, and knowing exactly which side of that line each fact falls on is what keeps your findings honest. This lesson classifies 802.11 frames by readability, pins down what encryption actually covers, and sets realistic expectations for what a key-less listener can — and cannot — recover.

## Why this matters

A wireless assessment lives or dies on honest scope. Claim you "saw the traffic" on a WPA2 network and you have overstated your access; claim you "learned nothing because it was encrypted" and you have understated a real privacy exposure (who talks to whom, when, how much, on which network). Modules 9 and 13 ask you to report impact precisely, and that starts here: cleartext management and control frames leak SSIDs, every device MAC, timing, and the mere presence of a handshake, while CCMP hides only the payload. Getting this boundary right is also what tells you when a "passive capture" plan will actually answer the question you were hired to answer.

## Learning objectives

- Classify 802.11 frames by **what a passive listener can read** with no key.
- Explain what **CCMP** protects and what it **leaves in the clear** on a WPA2/WPA3 network.
- State honestly what **passive capture** can and cannot recover, and where **PMF** changes the picture.

## Prerequisites

- [05.2 · Wireshark for 802.11](lesson-02.md) — you need to read the dissection tree and the Protected-Frame flag to see this boundary for yourself.

## Concept

### The readability line

Encryption on Wi-Fi protects the **payload of data frames**, not the frames that manage the link. Split the three 802.11 types ([01.3](../module-01/lesson-03.md)) by what a key-less listener gets:

| Frame type | Readable without a key? | What you can read |
|---|---|---|
| **Management** (beacon, probe, auth, assoc, deauth) | Yes (cleartext) | SSID, supported rates, RSN/security capabilities, the MACs, the whole management exchange |
| **Control** (ACK, RTS/CTS, Block Ack) | Yes (cleartext) | the addresses and timing of medium access |
| **Data** — **header** | Yes (always) | addresses, type/subtype, sequence, QoS, the **Protected** flag |
| **Data** — **payload** | **No** (CCMP-encrypted) | nothing — the upper-layer bytes are ciphertext without the key |

The rule to carry everywhere: **the MAC header is never encrypted; only the data payload is.** That is why, with no key at all, you can map who associates with whom, enumerate networks and clients, time events, and spot a handshake — and why you still cannot read a single byte of what was actually sent.

### What CCMP does and does not cover

WPA2 (and WPA3's data protection) encrypt and authenticate the data payload with **CCMP** (AES in CCM mode); WPA3 and newer modes may use **GCMP**. Either way, the cryptography covers the **frame body** and provides integrity over it — it does **not** encrypt the MAC header, because the header is what every receiver needs to route, acknowledge, and order frames before anyone could decrypt anything. So on a WPA2 network a captured data frame shows you a readable header and the **Protected Frame** bit set (`wlan.fc.protected == 1`), followed by ciphertext. You can confirm encryption is in force and see the conversation's shape; you cannot see its contents.

Two consequences people get wrong:

- **"It's encrypted, so capture is pointless"** — false. Traffic analysis (endpoints, volume, timing, which SSID, presence of a handshake or PMKID) is all cleartext metadata and is often enough to establish who was on which network and when.
- **"I can read the traffic, so it must be open"** — not necessarily. If you are reading *payloads*, either the network is open, or you hold the key (you captured the handshake and know the passphrase, so Wireshark decrypted it for you), or you are looking at the cleartext **header** and mistaking it for content.

### What you cannot infer without the key

Set honest limits. Without the session key you **cannot** read application data, URLs, DNS queries, credentials, or file contents; you cannot tell *what* a device did, only *that* it communicated, with whom, and how much. Even "which website" is hidden (that is inside the encrypted payload, and upper-layer protections like TLS would hide it again even on an open network). If a report needs payload content, passive key-less capture is the wrong tool and you should say so — the honest move the whole course is built around.

### Where PMF moves the line — slightly

Classic management frames are cleartext **and unauthenticated**, which is why forged deauth/disassoc frames work ([01.4](../module-01/lesson-04.md), Module 6). **Protected Management Frames (PMF / 802.11w)** add **integrity and replay protection to a subset of management frames** (notably deauth, disassoc, and certain action frames) so they cannot be forged — and WPA3 requires PMF. Note what PMF does **not** do: it does not encrypt beacons or probe responses (the SSID is still advertised in the clear), and it does not hide addressing. So PMF changes "can an attacker forge a management frame," not "can a passive listener read the SSID and the MACs" — those remain cleartext. Keep the two ideas separate: PMF is about **authenticity** of some management frames, not **confidentiality** of the air. (Full treatment in Module 12.)

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** even cleartext metadata is other people's data on a network you do not own. Analyse only your own allowlisted captures ([00.3](../module-00/lesson-03.md)); the readability of a frame is never authorisation to collect it.

## Hands-on

### Guided walkthrough — map the readability line in a capture (path R)

Recorded-data exercise: you read a capture we ship and transmit nothing.

1. From the module zip ([`labs/module-05/`](../../labs/module-05/)), open `wpa2-handshake-good.pcapng`. (Captures are **PENDING** — [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md); until then use any WPA2 capture with data frames.)
2. On a **beacon**, read the **SSID**, rates, and RSN security capabilities straight from the body — all cleartext — and note the MACs.
3. On a **data** frame, confirm `wlan.fc.protected == 1`, read the **header** (addresses, subtype, sequence), then try to read the payload and confirm it is **ciphertext** — you see that it is protected, not what it contains.
4. Build a one-page "readable vs not" table for this capture: for management, control, and data frames, list what you could read (SSID, MACs, timing, handshake presence) and what you could not (payload content).
5. State, in one line, what a report could *honestly* claim from this passive capture and what it could not.

> [!NOTE]
> **Lab paths:** R (classify readability in a supplied capture — no hardware; proves you can tell cleartext metadata from protected payload and scope a claim honestly, **not** that you captured anything live or decrypted anything). V/P not used — this is interpretation of a recorded file.
> **Start state:** module zip unpacked; Wireshark installed ([TOOLS.md](../../TOOLS.md)); supplied capture present (**PENDING** — [`labs/common/CAPTURES.md`](../../labs/common/CAPTURES.md)).
> **Duration:** ~20 min.
> **Artifacts:** the readable-vs-not table; the Protected-Frame bit reading on a data frame; the one-line honest-claim statement.
> **Troubleshooting:** you can read a payload → either the network is open, or Wireshark decrypted it because you supplied the key (check *Preferences → Protocols → IEEE 802.11*), or you are reading the cleartext header; no Protected bit on a data frame → the frame may be unprotected (open network) or a management frame; SSID blank → a hidden SSID ([04.2](../module-04/lesson-02.md)), still not "encrypted."
> **Cleanup:** none — nothing transmitted or captured.

## Exercise

A client asks you to run a purely passive capture on their WPA2-Personal office network and report "exactly what our staff are sending." After an afternoon of capture you have a clean trace full of protected data frames. Explain what you can honestly deliver from this capture, what you cannot, and what you would have to change about the engagement to answer the client's actual question — being precise about why the payload is out of reach.

<details>
<summary>Hint</summary>

Sort every fact the client wants into "lives in the MAC header / management frame" or "lives in the encrypted payload." Which bucket does "exactly what staff are sending" fall into? And what would it take — legitimately — to move something out of that bucket?
</details>

<details>
<summary>Reference answer</summary>

From a passive WPA2 capture you can **honestly deliver the cleartext metadata**: the SSID(s), every device MAC seen, who associated with which AP and when, traffic volume and timing per device, and the presence of handshakes/PMKIDs — a real picture of *who was on the network and how much they communicated*. You **cannot** deliver "exactly what staff are sending": the application data is in the **CCMP-encrypted payload**, so without the session key you see that frames are protected, not their contents — no messages, URLs, DNS, files, or credentials. The payload is out of reach by design (the MAC header stays clear so the network functions; only the body is encrypted), and even with the key, upper-layer TLS would hide most application content again. To answer the client's real question you would have to **change the engagement**: capture the handshake and use the (authorised) passphrase so Wireshark can decrypt payloads on their own network, or move to endpoint/host-based collection — and you should tell the client plainly that pure passive Wi-Fi capture cannot read payloads, rather than overstate what the trace shows.
</details>

## References

- [IEEE 802.11-2020](https://standards.ieee.org/ieee/802.11/7028/) — CCMP, the protected-frame handling, and the always-clear MAC header.
- [Wireshark display-filter reference — wlan](https://www.wireshark.org/docs/dfref/w/wlan.html) — `wlan.fc.protected` and the header fields readable without a key.
- [802.11w / PMF](https://en.wikipedia.org/wiki/IEEE_802.11w-2009) — integrity for a subset of management frames (detailed in Module 12).
- [01.3 · The 802.11 frame](../module-01/lesson-03.md) — why the MAC header is never encrypted.

## What you should now be able to do

- Classify management, control, and data frames by what a key-less listener can read.
- Explain that CCMP protects the data payload while the MAC header stays cleartext on WPA2/WPA3.
- Scope a passive-capture claim honestly, and say where PMF changes authenticity but not readability.
