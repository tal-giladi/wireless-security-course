---
id: "01.3"
module: 1
minutes: 22
practice_minutes: 15
prerequisites: ["01.1"]
objectives:
  - Identify the three 802.11 frame types and the key subtypes a tester cares about.
  - Read the 802.11 MAC header — frame control, the address fields, ToDS/FromDS, and the FCS.
  - Explain the radiotap header prepended in monitor-mode captures and separate it from the 802.11 frame.
volatility: concept
sources:
  - title: "IEEE 802.11-2020 standard (MAC frame formats and addressing)"
    url: https://standards.ieee.org/ieee/802.11/7028/
  - title: "The radiotap header specification and defined fields"
    url: https://www.radiotap.org/
last_verified: "2026-10-01"
---

# 01.3 · The 802.11 frame — management, control, data, addressing, and radiotap

Everything you will capture, filter, and attack in this course is made of 802.11 frames, so being able to read one — its type, its addresses, and the radio metadata wrapped around it in a capture — is the single most transferable skill in the foundations. This lesson dissects the 802.11 MAC header field by field, explains the three/four address scheme and the ToDS/FromDS bits that decide what those addresses mean, and separates the real frame from the radiotap header your monitor interface prepends.

## Why this matters

Later modules talk about beacons, deauthentication, EAPOL handshake messages, and probe requests as if you can already spot them in a trace — because by the end of this lesson you can. Confusing the radiotap header (metadata your own adapter added) with the actual over-the-air frame is one of the most common beginner errors, and it leads people to "find" fields that were never transmitted. Reading addressing correctly is what lets you tell *who sent what to whom*, which underpins recognising an attack, scoping a capture to your own gear, and writing honest findings.

## Learning objectives

- Identify the **three frame types** (management, control, data) and the **key subtypes** a tester watches for.
- Read the **802.11 MAC header** — frame control, the **address fields**, **ToDS/FromDS**, and the **FCS**.
- Explain the **radiotap header** in monitor captures and keep it distinct from the 802.11 frame itself.

## Prerequisites

- [01.1 · Radio basics for hackers](lesson-01.md) — you read RSSI and channel from the radiotap header there; here you learn what else it carries and what sits beneath it.

## Concept

### How it works on the wire

Every 802.11 frame begins with a **MAC header**, followed (for some types) by a payload, and ends with a 4-byte **Frame Check Sequence (FCS)** — a CRC the receiver uses to discard corrupted frames. The header starts with a 2-byte **Frame Control** field whose **Type** (2 bits) and **Subtype** (4 bits) identify the frame.

**The three types:**

- **Management (type 0)** — frames that build and tear down the association relationship: **beacon**, **probe request/response**, **authentication**, **association request/response**, **reassociation**, **deauthentication**, and **disassociation**. These carry no user data but are where most Wi-Fi attacks live.
- **Control (type 1)** — short frames that regulate access to the medium: **ACK**, **RTS/CTS**, **Block Ack**, **PS-Poll**. They coordinate who transmits when.
- **Data (type 2)** — frames carrying the actual payload. A key subtype is **QoS Data**; the **EAPOL** frames of the WPA2/WPA3 4-way handshake ride inside data frames and are central to Module 6.

| Type | Example subtypes | What a tester does with them |
|---|---|---|
| Management | beacon, probe req/resp, auth, assoc, deauth | enumerate networks/clients; recognise deauth and rogue beacons |
| Control | ACK, RTS/CTS, Block Ack | understand timing; rarely attacked directly |
| Data | Data, QoS Data (carries EAPOL) | find the handshake; see what is encrypted |

### The MAC header and the address fields

After Frame Control comes a **Duration/ID** field, then **up to four MAC address fields**, a **Sequence Control** field, and (for QoS frames) a QoS control field. The addressing is the part that trips people up, because what each address *means* depends on two bits in Frame Control: **ToDS** and **FromDS** ("DS" = the distribution system, i.e. the wired side behind the AP).

| ToDS | FromDS | Scenario | Addr1 (RA) | Addr2 (TA) | Addr3 | Addr4 |
|---|---|---|---|---|---|---|
| 0 | 0 | IBSS / management (e.g. client ↔ client, or to AP) | DA | SA | BSSID | — |
| 0 | 1 | From AP to client (downlink) | DA | BSSID | SA | — |
| 1 | 0 | From client to AP (uplink) | BSSID | SA | DA | — |
| 1 | 1 | AP-to-AP (WDS/mesh bridge) | RA | TA | DA | SA |

**Addr1 is always the receiver (RA)** and **Addr2 is always the transmitter (TA)** of this particular hop — that much never changes, which is why you can always answer "who transmitted this frame and who is meant to receive it" from Addr1/Addr2 alone. Addr3 (and Addr4 in the rare four-address case) carry the original source/destination and the BSSID, and their roles shuffle according to the DS bits. The **BSSID** identifies the cell (usually the AP's MAC); the DA/SA are the ultimate destination/source.

> [!NOTE]
> **LAB TARGET vs REAL NETWORK:** reading addressing is also how you keep a capture honest. If Addr1/Addr2/BSSID are not the MACs on your [00.3](../module-00/lesson-03.md) allowlist, you are looking at a network you do not own — stop and re-scope.

### Protected frames and what you can still read

A bit in Frame Control (**Protected Frame**) marks a frame whose payload is encrypted. Crucially, the **MAC header is not encrypted** — addresses, type/subtype, and sequence numbers are always visible, even on a WPA2/WPA3 network. That is why you can map who talks to whom, count frames, and spot management activity without any key; only the data *payload* is protected. (Module 5 goes deep on cleartext-vs-protected.)

### The radiotap header — metadata, not part of the frame

When you capture in monitor mode, your adapter prepends a **radiotap header** to each frame before handing it to the capture file. Radiotap is **not transmitted over the air** — it is your receiver's annotation, carrying RF metadata: channel frequency, data rate, **antenna signal (dBm)** and noise, MCS/VHT/HE info, and flags (e.g. whether the FCS was present or bad). Its first bytes are a version, length, and a **`it_present` bitmap** that says which fields follow; all values are little-endian.

The practical rule: **radiotap is how you heard the frame; the 802.11 header is the frame.** When you report "the client sent a deauth," that fact comes from the 802.11 header; "I heard it at −52 dBm on channel 6" comes from radiotap. Never attribute a radiotap field to the device under test — the device never sent it.

## Hands-on

### Guided walkthrough — dissect frames from a supplied capture

Recorded-data exercise: you read a capture we ship and transmit nothing.

1. From the module zip (`labs/module-01/`), open `captures/frame-types-sample.pcapng` in Wireshark.
2. Find one of each type: a **beacon** (management), an **ACK** (control), and a **data/QoS Data** frame. For each, read the **Type/Subtype** in the Frame Control field.
3. On a frame between a client and the AP, read **ToDS** and **FromDS**, then identify **Addr1 (RA)**, **Addr2 (TA)**, and the **BSSID**. State the direction (uplink/downlink) and confirm it against the table above.
4. Expand the **radiotap header** on the same frame and list two fields it carries (e.g. channel, signal). Confirm these are *not* inside the 802.11 header.
5. Check the **Protected Frame** flag on a data frame and note that the header is readable even when the payload is encrypted.

> [!NOTE]
> **Lab paths:** R (dissect supplied captures — no hardware; proves you can read frame type, addressing, and radiotap, not that you captured anything live). V/P not used in this foundation lesson.
> **Start state:** module zip unpacked; Wireshark installed.
> **Duration:** ~15 min.
> **Artifacts:** a short table — for three frames, their type/subtype, ToDS/FromDS, Addr1/Addr2/BSSID, and two radiotap fields.
> **Cleanup:** none — nothing transmitted or captured.

## Exercise

You are handed a single captured frame. Its 802.11 header shows ToDS=1, FromDS=0; the radiotap header reports −48 dBm on channel 6. Explain which address field holds the AP's MAC, which holds the client, the direction of the frame, and why you must not report the −48 dBm as something the client "transmitted at."

<details>
<summary>Hint</summary>

Use the ToDS/FromDS row for "from client to AP." Remember Addr1 is always the receiver and Addr2 the transmitter of this hop. Then recall where the −48 dBm came from: did it travel over the air inside the frame, or did your own adapter add it?
</details>

<details>
<summary>Reference answer</summary>

ToDS=1, FromDS=0 is the **uplink** case (client → AP). So **Addr1 (RA) = the BSSID / AP's MAC** (the receiver of this hop), **Addr2 (TA) = the client's MAC** (the transmitter), and Addr3 carries the destination behind the AP. The frame is travelling from the client to the AP. The −48 dBm is a **radiotap** value — it is how *your* receiver heard the frame, not a property the client sent; reporting it as the client's transmit power confuses receiver metadata with the over-the-air frame. Correct phrasing: "I received the client's uplink frame at −48 dBm on channel 6."
</details>

## References

- IEEE 802.11-2020 — MAC frame formats, the four address fields, and ToDS/FromDS semantics (`../../references/README.md`).
- [The radiotap header](https://www.radiotap.org/) — the defined fields and the `it_present` bitmap.
- [00.3 · Safety, containment, and the law](../module-00/lesson-03.md) — using addressing to keep a capture on your own gear.

## What you should now be able to do

- Name the three 802.11 frame types and the key management/data subtypes a tester watches for.
- Read the MAC header — frame control, the address fields, ToDS/FromDS, and the FCS — and say who sent a frame to whom.
- Explain the radiotap header and keep its RF metadata distinct from the 802.11 frame the device actually transmitted.
